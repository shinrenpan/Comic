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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stateDataLoaded()
    }
}

// MARK: - Private

private extension DetailVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "詳細"
        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case .dataLoaded:
                self?.stateDataLoaded()
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

        vo.list.dataSource = self
        vo.list.delegate = self
        vo.list.refreshControl?.addAction(makeReloadAction(), for: .valueChanged)
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded() {
        navigationItem.rightBarButtonItem = makeFavoriteItem()
        contentUnavailableConfiguration = nil
        vo.reloadUI(model: vm.model)

        if firstInit {
            firstInit = false
            showLoadingUI()
            vm.doAction(.loadData)
        }
        else {
            if vm.model.episodes.isEmpty {
                showErrorUI(reload: makeReloadAction())
            }
        }
    }

    // MARK: - Make Something

    func makeFavoriteItem() -> UIBarButtonItem {
        let imgNamed = vm.model.comic.favorited ? "star.fill" : "star"
        let image = UIImage(systemName: imgNamed)

        let action = UIAction(image: image) { [weak self] _ in
            guard let self else { return }
            vm.doAction(.updateFavorite)
        }

        return .init(primaryAction: action)
    }

    func makeReloadAction() -> UIAction {
        .init { [weak self] _ in
            guard let self else { return }
            showLoadingUI()
            vm.doAction(.loadData)
        }
    }
}

// MARK: - UITableViewDataSource

extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.model.episodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reuseCell(UITableViewCell.self, for: indexPath)
        let episode = vm.model.episodes[indexPath.row]
        let watched = vm.model.comic.watchedId == episode.id

        var config = UIListContentConfiguration.cell()
        config.text = episode.title

        cell.contentConfiguration = config
        cell.accessoryType = watched ? .checkmark : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension DetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = vm.model.episodes[indexPath.row]
        router.toReader(comic: vm.model.comic, episode: episode)
    }
}
