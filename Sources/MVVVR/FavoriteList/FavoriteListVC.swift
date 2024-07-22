//
//  FavoriteListVC.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import SwiftData
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
            case let .cacheLoaded(comics):
                stateCacheLoaded(comics: comics)
            case let .favoriteRemoved(comic):
                stateFavoriteRemoved(comic: comic)
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
        vo.list.dataSource = dataSource
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateCacheLoaded(comics: [Comic]) {
        var snapshot = FavoriteListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = comics.isEmpty ? Self.makeEmpty() : nil
        }
    }

    func stateFavoriteRemoved(comic: Comic) {
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

        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeRemoveAction(indexPath: indexPath)
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeRemoveAction(indexPath: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> FavoriteListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, cellType: .favorite)
            }
        }
    }

    func makeDataSource() -> FavoriteListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeRemoveAction(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let action = UIContextualAction(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
            self?.vm.doAction(.removeFavorite(comic: comic))
        }

        action.backgroundColor = .orange

        return .init(actions: [action])
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
