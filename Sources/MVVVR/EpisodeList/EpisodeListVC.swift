//
//  EpisodeListVC.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import Combine
import UIKit

final class EpisodeListVC: UIViewController {
    let vo = EpisodeListVO()
    let vm: EpisodeListVM
    let router = EpisodeListRouter()
    var binding: Set<AnyCancellable> = .init()
    weak var delegate: EpisodeListModel.SelectedDelegate?
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
        vm.doAction(.loadData)
    }
}

// MARK: - Private

private extension EpisodeListVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "集數"
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self else { return }
            if viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                stateNone()
            case let .dataLoaded(response):
                stateDataLoaded(response: response)
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
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded(response: EpisodeListModel.DataLoadedResponse) {
        let episodes = response.episodes
        var snapshot = EpisodeListModel.Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(episodes, toSection: 0)
        snapshot.reloadSections([0])

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }

            contentUnavailableConfiguration = episodes.isEmpty ? Self.makeEmpty() : nil
            vo.scrollListToWatched(indexPath: getWatchedIndexPath())
        }
    }

    // MARK: - Make Something

    func makeCell() -> EpisodeListModel.CellRegistration {
        .init { cell, _, episode in
            var config = UIListContentConfiguration.cell()
            config.text = episode.data.title
            cell.contentConfiguration = config
            cell.accessories = episode.selected ? [.checkmark()] : []
        }
    }

    func makeDataSource() -> EpisodeListModel.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }
    
    // MARK: - Get Something
    
    func getWatchedIndexPath() -> IndexPath? {
        let items = dataSource.snapshot().itemIdentifiers

        guard let index = items.firstIndex(where: { $0.selected }) else {
            return nil
        }

        return .init(item: index, section: 0)
    }
}

// MARK: - UICollectionViewDelegate

extension EpisodeListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.episodeList(list: self, selected: episode.data)
    }
}
