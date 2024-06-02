//
//  HistoryModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

enum HistoryModels {}

// MARK: - Action

extension HistoryModels {
    enum Action {
        case loadCache
        case updateFavorite(comic: Comic)
        case removeHistory(comic: Comic)
    }
}

// MARK: - State

extension HistoryModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
        case dataUpdated(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension HistoryModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension HistoryModels {
    final class DisplayModel {}
}
