//
//  SearchListVC.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import SwiftData
import SwiftUI
import UIKit

final class SearchListVC: UIViewController {
    let vo = SearchListVO()
    let vm = SearchListVM()
    let router = SearchListRouter()
    var binding: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }
}

// MARK: - Private

private extension SearchListVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "搜尋"
        let searchVC = UISearchController()
        searchVC.searchBar.placeholder = "漫畫名稱"
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        navigationItem.preferredSearchBarPlacement = .stacked
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case let .dataLoaded(comics):
                self?.stateDataLoaded(comics: comics)
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

        vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
        vo.list.dataSource = dataSource
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded(comics: [Comic]) {
        vo.reloadUI(comics: comics, dataSource: dataSource)
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
            guard let comic = dataSource.itemIdentifier(for: indexPath) else { return nil }

            return makeFavoriteActionForComic(comic)
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }
            guard let comic = dataSource.itemIdentifier(for: indexPath) else { return nil }

            return makeFavoriteActionForComic(comic)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> SearchListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SearchListContentView(comic: item)
            }
        }
    }

    func makeDataSource() -> SearchListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeFavoriteActionForComic(_ comic: Comic) -> UISwipeActionsConfiguration {
        let favorited = comic.favorited
        let title = favorited ? "取消收藏" : "加入收藏"

        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            self?.vm.doAction(.updateFavorite(comic: comic))
        }

        action.backgroundColor = favorited ? .orange : .blue

        return .init(actions: [action])
    }

    func makeKeywords(origin: String?) -> String? {
        guard let origin else {
            return nil
        }

        if vo.zhHansSwitcher.isOn {
            return origin.gb
        }

        return origin.big5
    }
}

// MARK: - UICollectionViewDelegate

extension SearchListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comic: comic)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let keywords = makeKeywords(origin: searchController.searchBar.text)
        vm.doAction(.search(keywords: keywords))
    }
}

// MARK: - ScrollToTopable

extension SearchListVC: ScrollToTopable {
    func scrollToTop() {
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
