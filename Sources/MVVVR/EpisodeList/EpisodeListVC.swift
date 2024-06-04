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
    weak var delegate: EpisodeListDelegate?
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
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case let .dataLoaded(episodes, watchId):
                self?.stateDataLoaded(episodes: episodes, watchId: watchId)
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

    func stateDataLoaded(episodes: [Comic.Episode], watchId: String?) {
        let row = episodes.firstIndex(where: { $0.id == watchId })
        var snapshot = EpisodeListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(episodes, toSection: .main)
        snapshot.reloadSections([.main])

        dataSource.apply(snapshot) {
            if let row {
                self.vo.list.scrollToRow(at: .init(row: row, section: 0), at: .top, animated: true)
            }
        }
    }

    func makeDataSource() -> EpisodeListModels.DataSource {
        .init(tableView: vo.list) { [weak self] tableView, indexPath, episode in
            let watched = self?.vm.model.comic.watchedId == episode.id
            var config = UIListContentConfiguration.cell()
            config.text = episode.title

            let cell = tableView.reuseCell(UITableViewCell.self, for: indexPath)
            cell.contentConfiguration = config
            cell.accessoryType = watched ? .checkmark : .none

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension EpisodeListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let epidose = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.list(self, selected: epidose)
    }
}
