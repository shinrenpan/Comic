//
//  HistoryListVC.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import SwiftData
import SwiftUI
import UIKit

final class HistoryListVC: UIViewController {
    let vo = HistoryListVO()
    let vm = HistoryListVM()
    let router = HistoryListRouter()
    var binding: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.doAction(.loadCache)
    }
}

// MARK: - Private

private extension HistoryListVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "觀看紀錄"
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
        showEmptyUI(isEmpty: comics.isEmpty)
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

    func makeCell() -> HistoryListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, inFavoriteList: false)
            }
        }
    }

    func makeDataSource() -> HistoryListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeSwipeActionsForIndexPath(_ indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let result = UISwipeActionsConfiguration(actions: [
            makeHistoryActionForComic(comic),
            makeFavoriteActionForComic(comic),
        ])

        result.performsFirstActionWithFullSwipe = false

        return result
    }

    func makeHistoryActionForComic(_ comic: Comic) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "移除紀錄") { [weak self] _, _, _ in
            self?.vm.doAction(.removeHistory(comic: comic))
        }

        action.backgroundColor = .red

        return action
    }

    func makeFavoriteActionForComic(_ comic: Comic) -> UIContextualAction {
        let favorited = comic.favorited
        let title = favorited ? "取消收藏" : "加入收藏"

        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            self?.vm.doAction(.updateFavorite(comic: comic))
        }

        action.backgroundColor = favorited ? .orange : .blue

        return action
    }
}

// MARK: - UICollectionViewDelegate

extension HistoryListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comic: comic)
    }
}

// MARK: - ScrollToTopable

extension HistoryListVC: ScrollToTopable {
    func scrollToTop() {
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
