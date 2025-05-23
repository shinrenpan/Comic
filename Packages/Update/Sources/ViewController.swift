//
//  ViewController.swift
//  Update
//
//  Created by Joe Pan on 2025/3/5.
//

import SwiftUI
import UIKit
import CustomUI

public final class ViewController: UIViewController {
    private var firstInit = true
    private let vo = ViewOutlet()
    private let vm = ViewModel()
    private let router = Router()
    private lazy var dataSource = makeDataSource()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSearchOrLoadCache()
    }
}

// MARK: - Private

private extension ViewController {
    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "更新列表"
        navigationItem.rightBarButtonItem = vo.searchItem
        
        vo.searchItem.primaryAction = .init(title: "線上搜尋") { [weak self] _ in
            guard let self else { return }
            router.toRemoteSearch()
        }
        
        let searchVC = UISearchController()
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.placeholder = "本地搜尋漫畫名稱"
        navigationItem.searchController = searchVC
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false
        
        router.vc = self
    }
    
    func setupBinding() {
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
                case let .localSearched(response):
                    stateLocalSearched(response: response)
                case let .favoriteChanged(response):
                    stateFavoriteChanged(response: response)
                }
                
                setupBinding()
            }
        }
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
    
    func stateNone() {}
    
    func stateDataLoaded(response: DataLoadedResponse) {
        hideLoading()
        
        let comics = response.comics
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)
        
        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            updateAfterDataLoaded()
        }
    }
    
    func stateLocalSearched(response: LocalSearchedResponse) {
        let comics = response.comics
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(comics, toSection: 0)
        
        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            showEmptyContent(isEmpty: comics.isEmpty, text: "找不到漫畫")
        }
    }
    
    func stateFavoriteChanged(response: FavoriteChangedResponse) {
        var snapshot = dataSource.snapshot()
        
        guard let old = snapshot.itemIdentifiers.first(where: { response.comic.id == $0.id }) else {
            return
        }
        
        snapshot.insertItems([response.comic], beforeItem: old)
        snapshot.deleteItems([old])
        dataSource.apply(snapshot)
    }
    
    func updateAfterDataLoaded() {
        if firstInit {
            firstInit = false
            showLoading(onWindow: true)
            vm.doAction(.loadRemote)
        }
        else {
            if dataSource.snapshot().itemIdentifiers.isEmpty {
                showErrorContent(action: makeReloadAction())
            }
            else {
                contentUnavailableConfiguration = nil
            }
        }
    }
    
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
            vm.doAction(.changeFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .blue)
    }
    
    func makeRemoveFavoriteAction(comic: Comic) -> UIContextualAction {
        .init(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
            guard let self else { return }
            vm.doAction(.changeFavorite(request: .init(comic: comic)))
        }.setup(\.backgroundColor, value: .orange)
    }
    
    func makeCell() -> CellRegistration {
        .init { cell, _, comic in
            cell.contentConfiguration = UIHostingConfiguration {
                Cell(comic: comic)
            }
        }
    }
    
    func makeDataSource() -> DataSource {
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
            showLoading(onWindow: true)
            vm.doAction(.loadRemote)
            vo.list.panGestureRecognizer.isEnabled = true
        }
    }
    
    func doSearchOrLoadCache() {
        if let keywords = getSearchKeywords() {
            vm.doAction(.localSearch(request: .init(keywords: keywords)))
        }
        else {
            vm.doAction(.loadData)
        }
    }
    
    func getSearchKeywords() -> String? {
        guard let result = navigationItem.searchController?.searchBar.text?.gb else {
            return nil
        }
        
        return result.isEmpty ? nil : result
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comicId: comic.id)
    }
}

// MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        doSearchOrLoadCache()
    }
}

// MARK: - ScrollToTopable

extension ViewController: TabBarController.ScrollToTopable {
    public func scrollToTop() {
        if dataSource.snapshot().itemIdentifiers.isEmpty { return }
        
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
