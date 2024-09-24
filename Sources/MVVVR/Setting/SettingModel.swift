//
//  SettingModel.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

enum SettingModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingModel.Item>
}

// MARK: - Action

extension SettingModel {
    enum Action {
        case loadData
        case cleanFavorite
        case cleanHistory
        case cleanCache
    }
}

// MARK: - State

extension SettingModel {
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }
    
    struct DataLoadedResponse {
        let items: [Item]
    }
}

// MARK: - Models

extension SettingModel {
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
