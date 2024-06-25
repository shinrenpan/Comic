//
//  UpdateListModels.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

enum UpdateListModels {}

// MARK: - Action

extension UpdateListModels {
    enum Action {
        case loadCache
        case loadData
        /// 本地搜尋
        case localSearch(keywords: String)
        case updateFavorite(comic: Comic)
    }
}

// MARK: - State

extension UpdateListModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
        case dataUpdated(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension UpdateListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension UpdateListModels {
    final class DisplayModel {}
}
