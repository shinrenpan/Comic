//
//  UpdateListModels.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

enum UpdateListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
}

// MARK: - Action

extension UpdateListModels {
    enum Action {
        case loadCache
        case loadRemote
        /// 本地搜尋
        case localSearch(keywords: String)
        case addFavorite(comic: Comic)
        case removeFavorite(comic: Comic)
    }
}

// MARK: - State

extension UpdateListModels {
    enum State {
        case none
        case cacheLoaded(comics: [Comic])
        case remoteLoaded(comics: [Comic])
        case searchResult(comics: [Comic])
        case favoriteAdded(comic: Comic)
        case favoriteRemoved(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension UpdateListModels {
    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension UpdateListModels {
    final class DisplayModel {}
}
