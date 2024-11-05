//
//  SearchModel.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import UIKit

extension Search {

    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayComic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayComic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayComic>
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData(request: LoadDataRequest)
        case loadNextPage(request: LoadNextPageRequest)
        case changeFavorite(request: ChangeFavoriteRequest)
    }
    
    struct LoadDataRequest {
        let keywords: String
    }
    
    struct LoadNextPageRequest {
        let keywords: String
    }
    
    struct ChangeFavoriteRequest {
        let comic: DisplayComic
    }
    
    // NARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
        case nextPageLoaded(response: NextPageLoadedResponse)
        case favoriteChanged(response: FavoriteChangedResponse)
    }
    
    struct DataLoadedResponse {
        let comics: [DisplayComic]
    }
    
    struct NextPageLoadedResponse {
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
