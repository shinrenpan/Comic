//
//  ViewController.swift
//  Setting
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit

public final class ViewController: UIViewController {
    private let vo = ViewOutlet()
    private let vm = ViewModel()
    private let router = Router()
    private lazy var dataSource = makeDataSource()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.doAction(.loadData)
    }
}

// MARK: - Private

private extension ViewController {
    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "設置"
        router.vc = self
    }
    
    func setupBinding() {
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
    
    func stateNone() {}
    
    func stateDataLoaded(response: DataLoadedResponse) {
        hideLoading()
        
        let settings = response.settings
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(settings, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    func makeCell() -> CellRegistration {
        .init { cell, _, item in
            var config = UIListContentConfiguration.valueCell()
            config.text = item.title
            config.secondaryText = item.subTitle
            cell.contentConfiguration = config
        }
    }
    
    func makeDataSource() -> DataSource {
        let cell = makeCell()
        
        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }
    
    func makeSettingAction(setting: SettingItem) -> UIAlertAction {
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
    
    func doTap(setting: SettingItem, cell: UICollectionViewCell?) {
        switch setting.settingType {
        case .cacheSize, .favorite, .history:
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            let settingAction = makeSettingAction(setting: setting)
            router.showMenuForSetting(setting: setting, actions: [settingAction, cancel], cell: cell)
            
        case .localData, .version: // 點中本地端資料 / 版本不做事
            return
        }
    }
    
    func doCleanAction(action: Action) {
        showLoading(text: "Cleaning...")
        vm.doAction(action)
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let setting = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let cell = collectionView.cellForItem(at: indexPath)
        doTap(setting: setting, cell: cell)
    }
}
