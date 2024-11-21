//
//  FavoriteVC+Model.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension FavoriteVC {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayComic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayComic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayComic>

    // MARK: - Action / Request

    enum Action {
        case loadData
        case removeFavorite(request: RemoveFavoriteRequest)
    }

    struct RemoveFavoriteRequest {
        let comic: DisplayComic
    }

    // MARK: - State / Response

    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }

    struct DataLoadedResponse {
        let comics: [DisplayComic]
    }

    // MARK: - Models
    
    struct DisplayComic: Hashable {
        let id: String
        let title: String
        let coverURI: String
        let lastUpdate: TimeInterval
        let hasNew: Bool
        let note: String
        let watchDate: Date?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        init(comic: Database.Comic) {
            self.id = comic.id
            self.title = comic.title
            self.coverURI = comic.cover
            self.lastUpdate = comic.lastUpdate
            self.hasNew = comic.hasNew
            self.note = comic.note
            self.watchDate = comic.watchDate
        }
    }
}
