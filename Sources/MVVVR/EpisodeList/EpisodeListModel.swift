//
//  EpisodeListModel.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

enum EpisodeListModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Episode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Episode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode>

    /// Delegate for handling selected episode
    protocol SelectedDelegate: UIViewController {
        func episodeList(list: EpisodeListVC, selected episode: Comic.Episode)
    }
}

// MARK: - Action

extension EpisodeListModel {
    enum Action {
        case loadData
    }
}

// MARK: - State

extension EpisodeListModel {
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
    }
    
    struct DataLoadedResponse {
        let episodes: [Episode]
    }
}

// MARK: - Models

extension EpisodeListModel {
    final class Episode: NSObject {
        let data: Comic.Episode
        let selected: Bool

        init(data: Comic.Episode, selected: Bool) {
            self.data = data
            self.selected = selected
        }
    }
}
