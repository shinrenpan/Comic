//
//  UpdateListModels.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

enum UpdateListModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
}

// MARK: - Action

extension UpdateListModel {
    enum Action {
        case loadCache
        case loadRemote
        case localSearch(request: LocalSearchRequest)
        case addFavorite(request: AddFavoriteRequest)
        case removeFavorite(request: RemoveFavoriteRequest)
    }
    
    struct LocalSearchRequest {
        let keywords: String
    }
    
    struct AddFavoriteRequest {
        let comic: Comic
    }
    
    struct RemoveFavoriteRequest {
        let comic: Comic
    }
}

// MARK: - State

extension UpdateListModel {
    enum State {
        case none
        case cacheLoaded(response: CacheLoadedResponse)
        case remoteLoaded(response: RemoteLoadedResponse)
        case localSearched(response: LocalSearchedResponse)
        case favoriteAdded(response: FavoriteAddedResponse)
        case favoriteRemoved(response: FavoriteRemovedResponse)
    }
    
    struct CacheLoadedResponse {
        let comics: [Comic]
    }
    
    struct RemoteLoadedResponse {
        let comics: [Comic]
    }
    
    struct LocalSearchedResponse {
        let comics: [Comic]
    }
    
    struct FavoriteAddedResponse {
        let comic: Comic
    }
    
    struct FavoriteRemovedResponse {
        let comic: Comic
    }
}
