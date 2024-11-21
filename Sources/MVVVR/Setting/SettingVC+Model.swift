//
//  SettingVC+Model.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

extension SettingVC {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplaySetting>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplaySetting>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplaySetting>
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case cleanFavorite
        case cleanHistory
        case cleanCache
    }
    
    // MARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }
    
    struct DataLoadedResponse {
        let settings: [DisplaySetting]
    }
    
    // MARK: - Models
    
    enum SettingType {
        case localData
        case favorite
        case history
        case cacheSize
        case version
    }

    struct DisplaySetting: Hashable {
        let title: String
        let subTitle: String
        let settingType: SettingType
    }
}
