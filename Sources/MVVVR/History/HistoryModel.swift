//
//  HistoryListModels.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

extension History {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayComic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayComic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayComic>
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case addFavorite(request: AddFavoriteRequest)
        case removeFavorite(request: RemoveFavoriteRequest)
        case removeHistory(request: RemoveHistoryRequest)
    }
    
    struct AddFavoriteRequest {
        let comic: DisplayComic
    }
    
    struct RemoveFavoriteRequest {
        let comic: DisplayComic
    }
    
    struct RemoveHistoryRequest {
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
    
    struct DisplayComic: Hashable {
        let id: String
        let title: String
        let coverURI: String
        let favorited: Bool
        let lastUpdate: TimeInterval
        let hasNew: Bool
        let note: String
        let watchDate: Date?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        init(comic: Comic) {
            self.id = comic.id
            self.title = comic.title
            self.coverURI = comic.cover
            self.favorited = comic.favorited
            self.lastUpdate = comic.lastUpdate
            self.hasNew = comic.hasNew
            self.note = comic.note
            self.watchDate = comic.watchDate
        }
    }
}
