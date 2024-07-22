//
//  DetailVC.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import UIKit

final class DetailVC: UIViewController {
    let vo = DetailVO()
    let vm: DetailVM
    let router = DetailRouter()
    var binding: Set<AnyCancellable> = .init()
    lazy var dataSource = makeDataSource()
    var firstInit = true

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
        stateFavoriteUpdated()
        vm.doAction(.loadCache)
    }
}

// MARK: - Private

private extension DetailVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "詳細"
        navigationItem.rightBarButtonItem = vo.favoriteItem
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self else { return }
            if viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                stateNone()
            case let .cacheLoaded(episodes):
                stateCacheLoaded(episodes: episodes)
            case let .remoteLoaded(episodes):
                stateRemoteLoaded(episodes: episodes)
            case .favoriteUpdated:
                stateFavoriteUpdated()
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

        vo.list.delegate = self
        vo.list.refreshControl?.addAction(makeReloadAction(), for: .valueChanged)

        vo.favoriteItem.primaryAction = .init { [weak self] _ in
            guard let self else { return }
            vm.doAction(.tapFavorite)
        }
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateCacheLoaded(episodes: [DetailModels.DisplayEpisode]) {
        vo.header.reloadUI(comic: vm.model.comic)

        var snapshot = DetailModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(episodes, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }

            if firstInit {
                firstInit = false
                LoadingView.show()
                vm.doAction(.loadRemote)
            }
            else {
                updateWatchedUI()
            }
        }
    }

    func stateRemoteLoaded(episodes: [DetailModels.DisplayEpisode]) {
        LoadingView.hide()

        vo.header.reloadUI(comic: vm.model.comic)

        var snapshot = DetailModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(episodes, toSection: .main)

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }

            if episodes.isEmpty {
                var content = Self.makeError()
                content.buttonProperties.primaryAction = makeReloadAction()
                contentUnavailableConfiguration = content
            }
            else {
                contentUnavailableConfiguration = nil
                updateWatchedUI()
            }
        }
    }

    func stateFavoriteUpdated() {
        let imgNamed = vm.model.comic.favorited ? "star.fill" : "star"
        let image = UIImage(systemName: imgNamed)
        vo.favoriteItem.image = image
    }

    func makeCell() -> DetailModels.CellRegistration {
        .init { cell, _, item in
            var config = UIListContentConfiguration.cell()
            config.text = item.data.title
            cell.contentConfiguration = config
            cell.accessories = item.selected ? [.checkmark()] : []
        }
    }

    func makeDataSource() -> DetailModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeReloadAction() -> UIAction {
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

    func updateWatchedUI() {
        let items = dataSource.snapshot().itemIdentifiers

        guard let row = items.firstIndex(where: { $0.selected }) else {
            return
        }

        let indexPath = IndexPath(item: row, section: 0)
        vo.list.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension DetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        router.toReader(comic: vm.model.comic, episode: episode.data)
    }
}
