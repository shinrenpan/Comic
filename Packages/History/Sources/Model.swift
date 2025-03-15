//
//  Model.swift
//  History
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import DataBase

typealias DataSource = UICollectionViewDiffableDataSource<Int, Comic>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comic>
typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>
    
enum Action {
    case loadData
    case addFavorite(request: AddFavoriteRequest)
    case removeFavorite(request: RemoveFavoriteRequest)
    case removeHistory(request: RemoveHistoryRequest)
}

enum State {
    case none
    case dataLoaded(response: DataLoadedResponse)
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
    
struct DataLoadedResponse {
    let comics: [Comic]
}

struct Comic: Hashable {
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
    
    init(comic: DataBase.Comic) {
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
