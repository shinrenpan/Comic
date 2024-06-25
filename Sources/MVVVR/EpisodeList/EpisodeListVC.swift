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
    weak var selectedDelegate: EpisodeListModels.SelectedDelegate?
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
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case let .dataLoaded(response):
                self?.stateDataLoaded(response: response)
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

    func stateDataLoaded(response: EpisodeListModels.State.DataLoadedResponse) {
        let row = response.episodes.firstIndex(where: { $0.id == response.watchId })
        var snapshot = EpisodeListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(response.episodes, toSection: .main)
        snapshot.reloadSections([.main])

        dataSource.apply(snapshot) {
            if let row {
                self.vo.list.scrollToItem(at: .init(row: row, section: 0), at: .centeredVertically, animated: true)
            }
        }
    }

    // MARK: - Make Something

    func makeCell() -> EpisodeListModels.CellRegistration {
        .init { [weak self] cell, _, episode in
            let watched = self?.vm.model.comic.watchedId == episode.id
            var config = UIListContentConfiguration.cell()
            config.text = episode.title
            cell.contentConfiguration = config
            cell.accessories = watched ? [.checkmark()] : []
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
        guard let epidose = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        selectedDelegate?.list(self, selected: epidose)
    }
}
