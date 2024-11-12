//
//  EpisodePickerModel.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

extension EpisodePicker {
    // MARK: - Delegate
    
    protocol Delegate: UIViewController {
        func picker(picker: VC, selected episodeId: String)
    }
    
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, DisplayEpisode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DisplayEpisode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayEpisode>

    // MARK: - Action / Request
    
    enum Action {
        case loadData
    }
    
    // MARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }
    
    struct DataLoadedResponse {
        let episodes: [DisplayEpisode]
    }
    
    // MARK: - Models
    
    struct DisplayEpisode: Hashable {
        let id: String
        let title: String
        let selected: Bool
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        init(epidose: Database.Episode, selected: Bool) {
            self.id = epidose.id
            self.title = epidose.title
            self.selected = selected
        }
    }
}
