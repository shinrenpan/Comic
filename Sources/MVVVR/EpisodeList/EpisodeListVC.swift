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
    weak var delegate: EpisodeListModels.SelectedDelegate?
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
            case let .dataLoaded(episodes):
                stateDataLoaded(episodes: episodes)
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

        vo.list.dataSource = dataSource
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded(episodes: [EpisodeListModels.DisplayEpisode]) {
        var snapshot = EpisodeListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(episodes, toSection: .main)
        snapshot.reloadSections([.main])

        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }

            contentUnavailableConfiguration = episodes.isEmpty ? Self.makeEmpty() : nil

            if let row = episodes.firstIndex(where: { $0.selected }) {
                vo.list.scrollToItem(at: .init(row: row, section: 0), at: .centeredVertically, animated: false)
            }
        }
    }

    // MARK: - Make Something

    func makeCell() -> EpisodeListModels.CellRegistration {
        .init { cell, _, item in
            var config = UIListContentConfiguration.cell()
            config.text = item.data.title
            cell.contentConfiguration = config
            cell.accessories = item.selected ? [.checkmark()] : []
        }
    }

    func makeDataSource() -> EpisodeListModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
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
