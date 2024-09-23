//
//  FavoriteListModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

enum FavoriteListModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
}

// MARK: - Action

extension FavoriteListModel {
    enum Action {
        case loadCache
        case removeFavorite(request: RemoveFavoriteRequest)
    }
    
    struct RemoveFavoriteRequest {
        let comic: Comic
    }
}

// MARK: - State

extension FavoriteListModel {
    enum State {
        case none
        case cacheLoaded(response: CacheLoadedResponse)
        case favoriteRemoved(response: FavoriteRemovedResponse)
    }
    
    struct CacheLoadedResponse {
        let comics: [Comic]
    }
    
    struct FavoriteRemovedResponse {
        let comic: Comic
    }
}
