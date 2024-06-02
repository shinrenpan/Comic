//
//  SettingVC.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Combine
import UIKit

final class SettingVC: UIViewController {
    let vo = SettingVO()
    let vm = SettingVM()
    let router = SettingRouter()
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
        vm.doAction(.loadData)
    }
}

// MARK: - Private

private extension SettingVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "設置"
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

        vo.list.setCollectionViewLayout(makeListLayout(), animated: false)
        vo.list.dataSource = dataSource
        vo.list.delegate = self
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded() {
        vo.reloadUI(model: vm.model, dataSource: dataSource)
    }

    // MARK: - Make Something

    func makeListLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)

        return UICollectionViewCompositionalLayout.list(using: config)
    }

    func makeCell() -> SettingModels.CellRegistration {
        .init { cell, _, item in
            var config = UIListContentConfiguration.valueCell()
            config.text = item.title
            config.secondaryText = item.subTitle
            cell.contentConfiguration = config
        }
    }

    func makeDataSource() -> SettingModels.DataSource {
        let cell = makeCell()

        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }

    func makeActionForItem(_ item: SettingModels.Item) -> UIAlertAction {
        .init(title: "確定清除", style: .destructive) { [weak self] _ in
            switch item.settingType {
            case .favorite:
                self?.vm.doAction(.cleanFavorite)
            case .history:
                self?.vm.doAction(.cleanHistory)
            case .cacheSize:
                self?.vm.doAction(.cleanCache)
            case .version, .localData:
                break
            }
        }
    }

    // MARK: - Do Something

    func doTapItem(_ item: SettingModels.Item, for cell: UICollectionViewCell?) {
        switch item.settingType {
        // 點中本地端資料 / 版本不做事
        case .localData, .version:
            return
        case .cacheSize, .favorite, .history:
            let actions: [UIAlertAction] = [
                makeActionForItem(item),
                .init(title: "取消", style: .cancel),
            ]

            router.showMenuForItem(item, actions: actions, sourceView: cell)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SettingVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let cell = collectionView.cellForItem(at: indexPath)
        doTapItem(item, for: cell)
    }
}
