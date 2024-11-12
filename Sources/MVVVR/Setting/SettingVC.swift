//
//  SettingVC.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
import UIKit

extension Setting {
    final class VC: UIViewController {
        private let vo = VO()
        private let vm = VM()
        private let router = Router()
        private lazy var dataSource = makeDataSource()
        
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
        
        // MARK: - Setup Something

        private func setupSelf() {
            view.backgroundColor = vo.mainView.backgroundColor
            navigationItem.title = "設置"
            router.vc = self
        }

        private func setupBinding() {
            _ = withObservationTracking {
                vm.state
            } onChange: { [weak self] in
                guard let self else { return }
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if viewIfLoaded?.window == nil { return }
                    
                    switch vm.state {
                    case .none:
                        stateNone()
                    case let .dataLoaded(response):
                        stateDataLoaded(response: response)
                    }
                    
                    setupBinding()
                }
            }
        }

        private func setupVO() {
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

        private func stateNone() {}

        private func stateDataLoaded(response: DataLoadedResponse) {
            hideLoading()

            let settings = response.settings
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(settings, toSection: 0)
            dataSource.apply(snapshot)
        }
        
        // MARK: - Make Something

        private func makeCell() -> CellRegistration {
            .init { cell, _, item in
                var config = UIListContentConfiguration.valueCell()
                config.text = item.title
                config.secondaryText = item.subTitle
                cell.contentConfiguration = config
            }
        }

        private func makeDataSource() -> DataSource {
            let cell = makeCell()

            return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
            }
        }

        private func makeSettingAction(setting: DisplaySetting) -> UIAlertAction {
            .init(title: "確定清除", style: .destructive) { [weak self] _ in
                guard let self else { return }

                switch setting.settingType {
                case .favorite:
                    doCleanAction(action: .cleanFavorite)
                case .history:
                    doCleanAction(action: .cleanHistory)
                case .cacheSize:
                    doCleanAction(action: .cleanCache)
                case .version, .localData:
                    break
                }
            }
        }
        
        // MARK: - Do Something

        private func doTap(setting: DisplaySetting, cell: UICollectionViewCell?) {
            switch setting.settingType {
            case .cacheSize, .favorite, .history:
                let cancel = UIAlertAction(title: "取消", style: .cancel)
                let settingAction = makeSettingAction(setting: setting)
                router.showMenuForSetting(setting: setting, actions: [settingAction, cancel], cell: cell)

            case .localData, .version: // 點中本地端資料 / 版本不做事
                return
            }
        }

        private func doCleanAction(action: Action) {
            showLoading(text: "Cleaning...")
            vm.doAction(action)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Setting.VC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let setting = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let cell = collectionView.cellForItem(at: indexPath)
        doTap(setting: setting, cell: cell)
    }
}
