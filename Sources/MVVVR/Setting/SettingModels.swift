//
//  SettingModels.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

enum SettingModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingModels.Item>
}

// MARK: - Action

extension SettingModels {
    enum Action {
        /// 載入資料
        case loadData
        /// 清除所有收藏
        case cleanFavorite
        /// 清除所有觀看紀錄
        case cleanHistory
        /// 清除本地暫存圖片
        case cleanCache
    }
}

// MARK: - State

extension SettingModels {
    enum State {
        case none
        case dataLoaded(items: [Item])
    }
}

// MARK: - Other Model for DisplayModel

extension SettingModels {
    enum Section {
        case main
    }

    enum SettingType {
        /// 本地資料
        case localData
        /// 收藏紀錄
        case favorite
        /// 觀看紀錄
        case history
        /// 圖片暫存大小
        case cacheSize
        /// App 版號
        case version
    }

    final class Item: NSObject {
        /// 左邊 Title
        let title: String
        /// 右邊 Title
        let subTitle: String
        /// 類型
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
    final class DisplayModel {}
}
