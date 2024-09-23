//
//  DetailModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

enum DetailModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Episode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Episode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode>
}

// MARK: - Action

extension DetailModel {
    enum Action {
        case loadCache
        case loadRemote
        case tapFavorite
    }
}

// MARK: - State

extension DetailModel {
    enum State {
        case none
        case cacheLoaded(response: CacheLoadedResponse)
        case remoteLoaded(response: RemoteLoadedResponse)
        case favoriteUpdated(response: FavoriteUpdatedResponse)
    }
    
    struct CacheLoadedResponse {
        let comic: Comic
        let episodes: [Episode]
    }
    
    struct RemoteLoadedResponse {
        let comic: Comic
        let episodes: [Episode]
    }
    
    struct FavoriteUpdatedResponse {
        let comic: Comic
    }
}

// MARK: - Models

extension DetailModel {
    final class Episode: NSObject {
        let data: Comic.Episode
        let selected: Bool

        init(data: Comic.Episode, selected: Bool) {
            self.data = data
            self.selected = selected
        }
    }
}
