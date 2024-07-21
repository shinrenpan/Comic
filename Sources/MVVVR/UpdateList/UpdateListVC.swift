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
    lazy var dataSource = makeDataSource()
    var firstInit = true

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
            case let .cacheLoaded(comics):
                stateCacheLoaded(comics: comics)
            case let .remoteLoaded(comics):
                stateRemoteLoaded(comics: comics)
            case let .searchResult(comics):
                stateSearchResult(comics: comics)
            case let .favoriteAdded(comic):
                stateFavoriteAdded(comic: comic)
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

        vo.list.refreshControl?.addAction(makeReloadAction(), for: .valueChanged)
        vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
        vo.list.dataSource = dataSource
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateCacheLoaded(comics: [Comic]) {
        var snapshot = UpdateListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = nil

            if firstInit {
                LoadingView.show()
                firstInit = false
                vm.doAction(.loadRemote)
            }
        }
    }

    func stateRemoteLoaded(comics: [Comic]) {
        LoadingView.hide()

        var snapshot = UpdateListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            if comics.isEmpty {
                var content = Self.makeError()
                content.buttonProperties.primaryAction = makeReloadAction()
                contentUnavailableConfiguration = content
            }
            else {
                contentUnavailableConfiguration = nil
            }
        }
    }

    func stateSearchResult(comics: [Comic]) {
        var snapshot = UpdateListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = comics.isEmpty ? Self.makeEmpty(text: "找不到漫畫") : nil
        }
    }

    func stateFavoriteAdded(comic: Comic) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([comic])
        dataSource.apply(snapshot)
    }

    func stateFavoriteRemoved(comic: Comic) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([comic])
        dataSource.apply(snapshot)
    }

    // MARK: - Make Something

    func makeListLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 86, bottom: 0, trailing: 0)

        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeFavoriteAction(indexPath: indexPath)
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeFavoriteAction(indexPath: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> UpdateListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, cellType: .update)
            }
        }
    }

    func makeDataSource() -> UpdateListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeFavoriteAction(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let favorited = comic.favorited

        if favorited {
            let action = UIContextualAction(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
                self?.vm.doAction(.removeFavorite(comic: comic))
            }.setup(\.backgroundColor, value: .orange)

            return .init(actions: [action])
        }

        let action = UIContextualAction(style: .normal, title: "加入收藏") { [weak self] _, _, _ in
            self?.vm.doAction(.addFavorite(comic: comic))
        }.setup(\.backgroundColor, value: .blue)

        return .init(actions: [action])
    }

    func makeReloadAction() -> UIAction {
        UIAction { [weak self] _ in
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
        if let keywords = navigationItem.searchController?.searchBar.text?.gb,
           !keywords.isEmpty
        {
            vm.doAction(.localSearch(keywords: keywords))
        }
        else {
            vm.doAction(.loadCache)
        }
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
