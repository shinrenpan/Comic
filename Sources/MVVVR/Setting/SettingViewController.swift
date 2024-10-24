//
//  SettingVC.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
import UIKit

extension Setting {
    final class ViewController: UIViewController {
        let vo = ViewOutlet()
        let vm = ViewModel()
        let router = Router()
        lazy var dataSource = makeDataSource()
        
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
        
        // MARK: - Setup Something

        private func setupSelf() {
            view.backgroundColor = vo.mainView.backgroundColor
            navigationItem.title = "設置"
            router.vc = self
        }

        private func setupBinding() {
            _ = withObservationTracking {
                vm.state
            } onChange: {
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
            LoadingView.hide()

            let items = response.items
            var snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(items, toSection: 0)
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

        private func makeItemAction(item: Item) -> UIAlertAction {
            .init(title: "確定清除", style: .destructive) { [weak self] _ in
                guard let self else { return }

                switch item.settingType {
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

        private func doTapItem(item: Item, cell: UICollectionViewCell?) {
            switch item.settingType {
            case .cacheSize, .favorite, .history:
                let cancel = UIAlertAction(title: "取消", style: .cancel)
                let itemAction = makeItemAction(item: item)
                router.showMenuForItem(item: item, actions: [itemAction, cancel], cell: cell)

            case .localData, .version: // 點中本地端資料 / 版本不做事
                return
            }
        }

        private func doCleanAction(action: Action) {
            LoadingView.show(text: "Cleaning...")
            vm.doAction(action)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Setting.ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let cell = collectionView.cellForItem(at: indexPath)
        doTapItem(item: item, cell: cell)
    }
}
