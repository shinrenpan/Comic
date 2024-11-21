//
//  UpdateVC+Model.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

extension UpdateVC {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayComic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayComic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayComic>
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case loadRemote
        case localSearch(request: LocalSearchRequest)
        case changeFavorite(request: ChangeFavoriteRequest)
    }
    
    struct LocalSearchRequest {
        let keywords: String
    }
    
    struct ChangeFavoriteRequest {
        let comic: DisplayComic
    }
    
    // NARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
        case localSearched(response: LocalSearchedResponse)
        case favoriteChanged(response: FavoriteChangedResponse)
    }
    
    struct DataLoadedResponse {
        let comics: [DisplayComic]
    }
    
    struct LocalSearchedResponse {
        let comics: [DisplayComic]
    }
    
    struct FavoriteChangedResponse {
        let comic: DisplayComic
    }
    
    // MARK: - Models
    
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
        
        init(comic: Database.Comic) {
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
