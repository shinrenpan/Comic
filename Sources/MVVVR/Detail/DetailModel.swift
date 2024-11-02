//
//  DetailModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Detail {
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayEpisode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayEpisode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayEpisode>
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case loadRemote
        case tapFavorite
    }
    
    // MARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }
    
    struct DataLoadedResponse {
        let comic: DisplayComic?
        let episodes: [DisplayEpisode]
    }
    
    // MARK: - Models
    
    struct DisplayComic {
        let title: String
        let author: String
        let description: String?
        let coverURI: String
        let favorited: Bool
        
        init(comic: Comic) {
            self.title = comic.title
            self.author = comic.detail?.author ?? "Unknown"
            self.description = comic.detail?.desc
            self.coverURI = comic.cover
            self.favorited = comic.favorited
        }
    }
    
    struct DisplayEpisode: Hashable {
        let id: String
        let title: String
        let selected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        init(episode: Comic.Episode, selected: Bool) {
            self.id = episode.id
            self.title = episode.title
            self.selected = selected
        }
    }
}
