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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        searchVC.searchBar.placeholder = "漫畫名稱"
        navigationItem.searchController = searchVC
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false

        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case let .dataLoaded(comic):
                self?.stateDataLoaded(comics: comic)
            case let .dataUpdated(comic):
                self?.stateDataUpdated(comic: comic)
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

    func stateDataLoaded(comics: [Comic]) {
        vo.reloadUI(comics: comics, dataSource: dataSource)
        showEmptyUI(isEmpty: comics.isEmpty)

        if firstInit {
            firstInit = false
            showLoadingUI()
            vm.doAction(.loadData)
        }
        else {
            if comics.isEmpty, !isSearching() {
                showErrorUI(reload: makeReloadAction())
            }
        }
    }

    func stateDataUpdated(comic: Comic) {
        vo.reloadItem(comic, dataSource: dataSource)
    }

    // MARK: - Make Something

    func makeListLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 86, bottom: 0, trailing: 0)

        config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeSwipeActionsForIndexPath(indexPath)
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeSwipeActionsForIndexPath(indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> UpdateListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, inFavoriteList: false)
            }
        }
    }

    func makeDataSource() -> UpdateListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeSwipeActionsForIndexPath(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let favorited = comic.favorited
        let title = favorited ? "取消收藏" : "加入收藏"

        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.updateFavorite(comic: comic))
        }

        action.backgroundColor = favorited ? .orange : .blue

        return .init(actions: [action])
    }

    func makeReloadAction() -> UIAction {
        .init { [weak self] _ in
            guard let self else { return }
            if isSearching() {
                return
            }

            showLoadingUI()
            vm.doAction(.loadData)
        }
    }

    // MARK: - Do Something

    func doSearchOrLoadCache() {
        if let keywords = navigationItem.searchController?.searchBar.text?.gb,
           !keywords.isEmpty
        {
            vm.doAction(.search(keywords))
        }
        else {
            vm.doAction(.loadCache)
        }
    }

    // MARK: - Condition

    func isSearching() -> Bool {
        navigationItem.searchController?.isActive ?? false
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
