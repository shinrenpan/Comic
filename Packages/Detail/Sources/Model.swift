//
//  Model.swift
//  Detail
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import DataBase

typealias DataSource = UICollectionViewDiffableDataSource<Int, Episode>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Episode>
typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode>

enum Action {
    case loadData
    case loadRemote
    case tapFavorite
}

enum State {
    case none
    case dataLoaded(response: DataLoadedResponse)
}

struct DataLoadedResponse {
    let comic: Comic?
    let episodes: [Episode]
}

struct Comic {
    let title: String
    let author: String
    let description: String?
    let coverURI: String
    let favorited: Bool
    
    init(comic: DataBase.Comic) {
        self.title = comic.title
        self.author = comic.detail?.author ?? "Unknown"
        self.description = comic.detail?.desc
        self.coverURI = comic.cover
        self.favorited = comic.favorited
    }
}

struct Episode: Hashable {
    let id: String
    let title: String
    let selected: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(episode: DataBase.Episode, selected: Bool) {
        self.id = episode.id
        self.title = episode.title
        self.selected = selected
    }
}
