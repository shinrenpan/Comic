//
//  SettingModels.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

enum SettingModels {}

// MARK: - Action

extension SettingModels {
    enum Action {
        case loadData
        case cleanFavorite
        case cleanHistory
        case cleanCache
    }
}

// MARK: - State

extension SettingModels {
    enum State {
        case none
        case dataLoaded
    }
}

// MARK: - Other Model for DisplayModel

extension SettingModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingModels.Item>

    enum Section {
        case main
    }

    enum SettingType {
        case localData
        case favorite
        case history
        case cacheSize
        case version
    }

    final class Item: NSObject {
        let title: String
        let subTitle: String
        let settingType: SettingType

        init(title: String, subTitle: String, settingType: SettingType) {
            self.title = title
            self.subTitle = subTitle
            self.settingType = settingType
        }
    }
}

// MARK: - Display Model for ViewModel

extension SettingModels {
    final class DisplayModel {
        var items: [Item] = []
    }
}
