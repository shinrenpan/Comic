//
//  SearchListModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

enum SearchListModels {}

// MARK: - Action

extension SearchListModels {
    enum Action {
        case search(keywords: String?)
        case updateFavorite(comic: Comic)
    }
}

// MARK: - State

extension SearchListModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
        case dataUpdated(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension SearchListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension SearchListModels {
    final class DisplayModel {}
}
