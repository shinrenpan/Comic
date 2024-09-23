//
//  FavoriteListVC.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import SwiftUI
import UIKit

final class FavoriteListVC: UIViewController {
    let vo = FavoriteListVO()
    let vm = FavoriteListVM()
    let router = FavoriteListRouter()
    var binding: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        vm.doAction(.loadCache)
    }
}

// MARK: - Private

private extension FavoriteListVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "收藏列表"
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self else { return }
            if viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                stateNone()
            case let .cacheLoaded(response):
                stateCacheLoaded(response: response)
            case let .favoriteRemoved(response):
                stateFavoriteRemoved(response: response)
            }
        }.store(in: &binding)
    }

    func setupVO() {
        view.addSubview(vo.mainView)

        NSLayoutConstraint.activate([
            vo.mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vo.mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vo.mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vo.mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateCacheLoaded(response: FavoriteListModel.CacheLoadedResponse) {
        let comics = response.comics
        var snapshot = FavoriteListModel.Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = comics.isEmpty ? Self.makeEmpty() : nil
        }
    }

    func stateFavoriteRemoved(response: FavoriteListModel.FavoriteRemovedResponse) {
        let comic = response.comic
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([comic])

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = snapshot.itemIdentifiers.isEmpty ? Self.makeEmpty() : nil
        }
    }

    // MARK: - Make Something

    func makeListLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 86, bottom: 0, trailing: 0)
        config.leadingSwipeActionsConfigurationProvider = makeSwipeProvider()
        config.trailingSwipeActionsConfigurationProvider = makeSwipeProvider()

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeSwipeProvider() -> UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider {
        { [weak self] indexPath in
            guard let self else { return nil }

            return makeSwipeAction(indexPath: indexPath)
        }
    }
    
    func makeSwipeAction(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        return .init(actions: [makeRemoveFavoriteAction(comic: comic)])
    }
    
    func makeRemoveFavoriteAction(comic: Comic) -> UIContextualAction {
        .init(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.removeFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .orange)
    }
    
    func makeCell() -> FavoriteListModel.CellRegistration {
        .init { cell, _, comic in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: comic, cellType: .favorite)
            }
        }
    }

    func makeDataSource() -> FavoriteListModel.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FavoriteListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comic: comic)
    }
}

// MARK: - ScrollToTopable

extension FavoriteListVC: ScrollToTopable {
    func scrollToTop() {
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
