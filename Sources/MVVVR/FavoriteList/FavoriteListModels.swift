//
//  FavoriteListModels.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

enum FavoriteListModels {}

// MARK: - Action

extension FavoriteListModels {
    enum Action {
        case loadCache
        case removeFavorite(comic: Comic)
    }
}

// MARK: - State

extension FavoriteListModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
    }
}

// MARK: - Other Model for DisplayModel

extension FavoriteListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension FavoriteListModels {
    final class DisplayModel {}
}
