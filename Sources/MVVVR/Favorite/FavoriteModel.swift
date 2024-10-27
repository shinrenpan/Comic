//
//  FavoriteModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Favorite {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    // MARK: - Action / Request

    enum Action {
        case loadCache
        case removeFavorite(request: RemoveFavoriteRequest)
    }

    struct RemoveFavoriteRequest {
        let comic: Comic
    }

    // MARK: - State / Response

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
