//
//  FavoriteVC.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Observation
import SwiftUI
import UIKit

final class FavoriteVC: UIViewController {
    private let vo = VO()
    private let vm = VM()
    private let router = Router()
    private lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.doAction(.loadData)
    }
    
    // MARK: - Setup Something
    
    private func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "收藏列表"
        router.vc = self
    }
    
    private func setupBinding() {
        _ = withObservationTracking {
            vm.state
        } onChange: { [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                if viewIfLoaded?.window == nil { return }
                
                switch vm.state {
                case .none:
                    stateNone()
                case let .dataLoaded(response):
                    stateDataLoaded(response: response)
                }
                
                setupBinding()
            }
        }
    }
    
    private func setupVO() {
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
    
    private func stateNone() {}
    
    private func stateDataLoaded(response: DataLoadedResponse) {
        let comics = response.comics
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)
        
        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            showEmptyContent(isEmpty: comics.isEmpty)
        }
    }
    
    // MARK: - Make Something
    
    private func makeListLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 86, bottom: 0, trailing: 0)
        config.leadingSwipeActionsConfigurationProvider = makeSwipeProvider()
        config.trailingSwipeActionsConfigurationProvider = makeSwipeProvider()
        
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func makeSwipeProvider() -> UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider {
        { [weak self] indexPath in
            guard let self else { return nil }
            
            return makeSwipeAction(indexPath: indexPath)
        }
    }
    
    private func makeSwipeAction(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        return .init(actions: [makeRemoveFavoriteAction(comic: comic)])
    }
    
    private func makeRemoveFavoriteAction(comic: DisplayComic) -> UIContextualAction {
        .init(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.removeFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .orange)
    }
    
    private func makeCell() -> CellRegistration {
        .init { cell, _, comic in
            cell.contentConfiguration = UIHostingConfiguration {
                Cell(comic: comic)
            }
        }
    }
    
    private func makeDataSource() -> DataSource {
        let cell = makeCell()
        
        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FavoriteVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comicId: comic.id)
    }
}

// MARK: - ScrollToTopable

extension FavoriteVC: CustomTabBarVC.ScrollToTopable {
    func scrollToTop() {
        if dataSource.snapshot().itemIdentifiers.isEmpty { return }

        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
