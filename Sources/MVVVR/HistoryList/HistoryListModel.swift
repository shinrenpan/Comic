//
//  HistoryListModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

enum HistoryListModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
}

// MARK: - Action

extension HistoryListModel {
    enum Action {
        case loadCache
        case addFavorite(request: AddFavoriteRequest)
        case removeFavorite(request: RemoveFavoriteRequest)
        case removeHistory(request: RemoveHistoryRequest)
    }
    
    struct AddFavoriteRequest {
        let comic: Comic
    }
    
    struct RemoveFavoriteRequest {
        let comic: Comic
    }
    
    struct RemoveHistoryRequest {
        let comic: Comic
    }
}

// MARK: - State

extension HistoryListModel {
    enum State {
        case none
        case cacheLoaded(response: CacheLoadedResponse)
        case favoriteAdded(response: FavoriteAddedResponse)
        case favoriteRemoved(response: FavoriteRemovedResponse)
        case historyRemoved(response: HistoryRemovedResponse)
    }
    
    struct CacheLoadedResponse {
        let comics: [Comic]
    }
    
    struct FavoriteAddedResponse {
        let comic: Comic
    }
    
    struct FavoriteRemovedResponse {
        let comic: Comic
    }
    
    struct HistoryRemovedResponse {
        let comic: Comic
    }
}
