//
//  EpisodeListModel.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

extension EpisodePicker {
    // MARK: - Delegate
    
    protocol Delegate: UIViewController {
        func picker(picker: ViewController, selected episode: Comic.Episode)
    }
    
    // MARK: - Type Alias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Episode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Episode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode>

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
        let episodes: [Episode]
    }
    
    // MARK: - Models
    
    final class Episode: NSObject {
        let data: Comic.Episode
        let selected: Bool

        init(data: Comic.Episode, selected: Bool) {
            self.data = data
            self.selected = selected
        }
    }
}
