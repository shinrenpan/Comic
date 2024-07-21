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

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
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
            guard let self else { return }
            if viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                stateNone()
            case let .cacheLoaded(comics):
                stateCacheLoaded(comics: comics)
            case let .favoriteAdded(comic):
                stateFavoriteAdded(comic: comic)
            case let .favoriteRemoved(comic):
                stateFavoriteRemoved(comic: comic)
            case let .historyRemoved(comic):
                stateHistoryRemoved(comic: comic)
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

    func stateCacheLoaded(comics: [Comic]) {
        var snapshot = HistoryListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            contentUnavailableConfiguration = comics.isEmpty ? Self.makeEmpty() : nil
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

    func stateHistoryRemoved(comic: Comic) {
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

            return makeSwipeActions(indexPath: indexPath)
        }

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self else { return nil }

            return makeSwipeActions(indexPath: indexPath)
        }

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> HistoryListModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, cellType: .history)
            }
        }
    }

    func makeDataSource() -> HistoryListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeSwipeActions(indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        let result = UISwipeActionsConfiguration(actions: [
            makeHistoryAction(comic: comic),
            makeFavoriteAction(comic: comic),
        ])

        result.performsFirstActionWithFullSwipe = false

        return result
    }

    func makeHistoryAction(comic: Comic) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "移除紀錄") { [weak self] _, _, _ in
            self?.vm.doAction(.removeHistory(comic: comic))
        }

        action.backgroundColor = .red

        return action
    }

    func makeFavoriteAction(comic: Comic) -> UIContextualAction {
        let favorited = comic.favorited

        if favorited {
            let action = UIContextualAction(style: .normal, title: "取消收藏") { [weak self] _, _, _ in
                self?.vm.doAction(.removeFavorite(comic: comic))
            }.setup(\.backgroundColor, value: .orange)

            return action
        }

        let action = UIContextualAction(style: .normal, title: "加入收藏") { [weak self] _, _, _ in
            self?.vm.doAction(.addFavorite(comic: comic))
        }.setup(\.backgroundColor, value: .blue)

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
