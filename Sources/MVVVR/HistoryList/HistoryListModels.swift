//
//  HistoryListModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

enum HistoryListModels {}

// MARK: - Action

extension HistoryListModels {
    enum Action {
        case loadCache
        case updateFavorite(comic: Comic)
        case removeHistory(comic: Comic)
    }
}

// MARK: - State

extension HistoryListModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
        case dataUpdated(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension HistoryListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension HistoryListModels {
    final class DisplayModel {}
}
