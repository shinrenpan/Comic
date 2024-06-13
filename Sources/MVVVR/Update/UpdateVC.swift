//
//  UpdateVC.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import Combine
import SwiftUI
import UIKit

final class UpdateVC: UIViewController {
    let vo = UpdateVO()
    let vm = UpdateVM()
    let router = UpdateRouter()
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
        vm.doAction(.loadCache)
    }
}

// MARK: - Private

private extension UpdateVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "更新列表"
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
            if comics.isEmpty {
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

    func makeCell() -> UpdateModels.CellRegistration {
        .init { cell, _, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CellContentView(comic: item, inFavoriteList: false)
            }
        }
    }

    func makeDataSource() -> UpdateModels.DataSource {
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
            self?.showLoadingUI()
            self?.vm.doAction(.loadData)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension UpdateVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let comic = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toDetail(comic: comic)
    }
}

// MARK: - ScrollToTopable

extension UpdateVC: ScrollToTopable {
    func scrollToTop() {
        let zero = IndexPath(item: 0, section: 0)
        vo.list.scrollToItem(at: zero, at: .top, animated: true)
    }
}
