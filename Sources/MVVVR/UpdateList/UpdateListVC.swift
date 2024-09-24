//
//  UpdateListVC.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import Combine
import SwiftUI
import UIKit

final class UpdateListVC: UIViewController {
    let vo = UpdateListVO()
    let vm = UpdateListVM()
    let router = UpdateListRouter()
    var binding: Set<AnyCancellable> = .init()
    var firstInit = true
    lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        doSearchOrLoadCache()
    }
}

// MARK: - Private

private extension UpdateListVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "更新列表"
        navigationItem.rightBarButtonItem = vo.searchItem

        let searchVC = UISearchController()
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "本地搜尋漫畫名稱"
        navigationItem.searchController = searchVC
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false

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
            case let .remoteLoaded(response):
                stateRemoteLoaded(response: response)
            case let .localSearched(response):
                stateLocalSearched(response: response)
            case let .favoriteAdded(response):
                stateFavoriteAdded(response: response)
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

        vo.list.refreshControl?.addAction(makeReloadAction(), for: .valueChanged)
        vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateCacheLoaded(response: UpdateListModel.CacheLoadedResponse) {
        let comics = response.comics
        var snapshot = UpdateListModel.Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            updateCacheLoadedUI()
        }
    }

    func stateRemoteLoaded(response: UpdateListModel.RemoteLoadedResponse) {
        LoadingView.hide()

        let comics = response.comics
        var snapshot = UpdateListModel.Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            updateRemoteLoadedUI(isEmpty: comics.isEmpty)
        }
    }

    func stateLocalSearched(response: UpdateListModel.LocalSearchedResponse) {
        let comics = response.comics
        var snapshot = UpdateListModel.Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            updateLocalSearchedUI(isEmpty: comics.isEmpty)
        }
    }

    func stateFavoriteAdded(response: UpdateListModel.FavoriteAddedResponse) {
        let comic = response.comic
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([comic])
        dataSource.apply(snapshot)
    }

    func stateFavoriteRemoved(response: UpdateListModel.FavoriteRemovedResponse) {
        let comic = response.comic
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([comic])
        dataSource.apply(snapshot)
    }

    // MARK: - Update Something
    
    func updateCacheLoadedUI() {
        contentUnavailableConfiguration = nil

        if firstInit {
            LoadingView.show()
            firstInit = false
            vm.doAction(.loadRemote)
        }
    }
    
    func updateRemoteLoadedUI(isEmpty: Bool) {
        if isEmpty {
            var content = Self.makeError()
            content.buttonProperties.primaryAction = makeReloadAction()
            contentUnavailableConfiguration = content
        }
        else {
            contentUnavailableConfiguration = nil
        }
    }
    
    func updateLocalSearchedUI(isEmpty: Bool) {
        contentUnavailableConfiguration = isEmpty ? Self.makeEmpty(text: "找不到漫畫") : nil
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

        switch comic.favorited {
        case true:
            return .init(actions: [makeRemoveFavoriteAction(comic: comic)])
        case false:
            return .init(actions: [makeAddFavoriteAction(comic: comic)])
        }
    }
    
    func makeAddFavoriteAction(comic: Comic) -> UIContextualAction {
        .init(style: .normal, title: "加入收藏") { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.addFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .blue)
    }
    
    func makeRemoveFavoriteAction(comic: Comic) -> UIContextualAction {
        .init(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.removeFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .orange)
    }
    
    func makeCell() -> UpdateListModel.CellRegistration {
        .init { cell, _, comic in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: comic, cellType: .update)
            }
        }
    }

    func makeDataSource() -> UpdateListModel.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, comic in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: comic)
        }
    }

    func makeReloadAction() -> UIAction {
        .init { [weak self] _ in
            guard let self else { return }
            view.endEditing(true)
            navigationItem.searchController?.searchBar.text = nil
            navigationItem.searchController?.isActive = false
            vo.list.panGestureRecognizer.isEnabled = false // 停止下拉更新
            vo.list.refreshControl?.endRefreshing()
            LoadingView.show()
            vm.doAction(.loadRemote)
            vo.list.panGestureRecognizer.isEnabled = true
        }
    }

    // MARK: - Do Something

    func doSearchOrLoadCache() {
        if let keywords = getSearchKeywords() {
            vm.doAction(.localSearch(request: .init(keywords: keywords)))
        }
        else {
            vm.doAction(.loadCache)
        }
    }

    // MARK: - Get Something
    
    func getSearchKeywords() -> String? {
        guard let result = navigationItem.searchController?.searchBar.text?.gb else {
            return nil
        }
        
        return result.isEmpty ? nil : result
    }
}

// MARK: - UICollectionViewDelegate

extension UpdateListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comic: comic)
    }
}

// MARK: - UISearchResultsUpdating

extension UpdateListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        doSearchOrLoadCache()
    }
}

// MARK: - ScrollToTopable

extension UpdateListVC: ScrollToTopable {
    func scrollToTop() {
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
