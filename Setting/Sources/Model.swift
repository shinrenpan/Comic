//
//  Model.swift
//  Setting
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Int, SettingItem>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SettingItem>
typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem>

enum Action {
    case loadData
    case cleanFavorite
    case cleanHistory
    case cleanCache
}

enum State {
    case none
    case dataLoaded(response: DataLoadedResponse)
}

struct DataLoadedResponse {
    let settings: [SettingItem]
}

enum SettingType {
    case localData
    case favorite
    case history
    case cacheSize
    case version
}

struct SettingItem: Hashable {
    let title: String
    let subTitle: String
    let settingType: SettingType
}
