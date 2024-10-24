//
//  DetailVC.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Observation
import UIKit

extension Detail {
    final class ViewController: UIViewController {
        let vo = ViewOutlet()
        let vm: ViewModel
        let router = Router()
        var firstInit = true
        lazy var dataSource = makeDataSource()
        
        init(comic: Comic) {
            self.vm = .init(comic: comic)
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
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
        
        // MARK: - Setup Something

        private func setupSelf() {
            view.backgroundColor = vo.mainView.backgroundColor
            navigationItem.title = "詳細"
            navigationItem.rightBarButtonItem = vo.favoriteItem
            router.vc = self
        }

        private func setupBinding() {
            _ = withObservationTracking {
                vm.state
            } onChange: {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if viewIfLoaded?.window == nil { return }
                    
                    switch vm.state {
                    case .none:
                        stateNone()
                    case let .cacheLoaded(response):
                        stateCacheLoaded(response: response)
                    case let .remoteLoaded(response):
                        stateRemoteLoaded(response: response)
                    case let .favoriteUpdated(response):
                        stateFavoriteUpdated(response: response)
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

            vo.list.delegate = self
            vo.list.refreshControl?.addAction(makeReloadAction(), for: .valueChanged)

            vo.favoriteItem.primaryAction = .init { [weak self] _ in
                guard let self else { return }
                vm.doAction(.tapFavorite)
            }
        }
        
        // MARK: - Handle State

        private func stateNone() {}

        private func stateCacheLoaded(response: CacheLoadedResponse) {
            vo.reloadHeader(comic: response.comic)
            vo.reloadFavoriteUI(comic: response.comic)
            
            let episodes = response.episodes
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(episodes, toSection: 0)
            
            dataSource.apply(snapshot) { [weak self] in
                guard let self else { return }
                updateAfterCacheLoaded()
            }
        }

        private func stateRemoteLoaded(response: RemoteLoadedResponse) {
            LoadingView.hide()
            vo.reloadHeader(comic: response.comic)
            vo.reloadFavoriteUI(comic: response.comic)
            
            let episodes = response.episodes
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(episodes, toSection: 0)

            dataSource.apply(snapshot) { [weak self] in
                guard let self else { return }
                updateAfterRemoveLoaded(isEmpty: episodes.isEmpty)
            }
        }

        private func stateFavoriteUpdated(response: FavoriteUpdatedResponse) {
            vo.reloadFavoriteUI(comic: response.comic)
        }
        
        // MARK: - Make Something
        
        private func makeCell() -> CellRegistration {
            .init { cell, _, episode in
                var config = UIListContentConfiguration.cell()
                config.text = episode.data.title
                cell.contentConfiguration = config
                cell.accessories = episode.selected ? [.checkmark()] : []
            }
        }

        private func makeDataSource() -> DataSource {
            let cell = makeCell()

            return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
            }
        }

        private func makeReloadAction() -> UIAction {
            .init { [weak self] _ in
                guard let self else { return }
                navigationItem.searchController?.searchBar.text = nil
                navigationItem.searchController?.isActive = false
                vo.list.panGestureRecognizer.isEnabled = false // 停止下拉更新
                vo.list.refreshControl?.endRefreshing()
                LoadingView.show()
                vm.doAction(.loadRemote)
                vo.list.panGestureRecognizer.isEnabled = true
            }
        }
        
        // MARK: - Update Something

        private func updateAfterCacheLoaded() {
            if firstInit {
                firstInit = false
                LoadingView.show()
                vm.doAction(.loadRemote)
            }
            else {
                vo.scrollListToWatched(indexPath: getWatchedIndexPath())
            }
        }
        
        private func updateAfterRemoveLoaded(isEmpty: Bool) {
            if isEmpty {
                var content = Self.makeError()
                content.buttonProperties.primaryAction = makeReloadAction()
                contentUnavailableConfiguration = content
            }
            else {
                contentUnavailableConfiguration = nil
                vo.scrollListToWatched(indexPath: getWatchedIndexPath())
            }
        }
        
        // MARK: - Get Something
        
        private func getWatchedIndexPath() -> IndexPath? {
            let items = dataSource.snapshot().itemIdentifiers

            guard let index = items.firstIndex(where: { $0.selected }) else {
                return nil
            }

            return .init(item: index, section: 0)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Detail.ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toReader(comic: vm.comic, episode: episode.data)
    }
}
