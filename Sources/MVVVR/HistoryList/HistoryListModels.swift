//
//  HistoryListModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

enum HistoryListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
}

// MARK: - Action

extension HistoryListModels {
    enum Action {
        case loadCache
        case addFavorite(comic: Comic)
        case removeFavorite(comic: Comic)
        case removeHistory(comic: Comic)
    }
}

// MARK: - State

extension HistoryListModels {
    enum State {
        case none
        case cacheLoaded(comics: [Comic])
        case favoriteAdded(comic: Comic)
        case favoriteRemoved(comic: Comic)
        case historyRemoved(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension HistoryListModels {
    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension HistoryListModels {
    final class DisplayModel {}
}
