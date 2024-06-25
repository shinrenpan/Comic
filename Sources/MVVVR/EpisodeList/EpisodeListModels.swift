//
//  EpisodeListModels.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

enum EpisodeListModels {}

// MARK: - Action

extension EpisodeListModels {
    enum Action {
        case loadData
    }
}

// MARK: - State

extension EpisodeListModels {
    enum State {
        case none

        /// DataLoaded Response
        struct DataLoadedResponse {
            let episodes: [Comic.Episode]
            let watchId: String?
        }

        case dataLoaded(response: DataLoadedResponse)
    }
}

// MARK: - Others

extension EpisodeListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic.Episode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic.Episode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic.Episode>

    /// Delegate for handling selected episode
    protocol SelectedDelegate: UIViewController {
        func list(_ list: EpisodeListVC, selected episode: Comic.Episode)
    }

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension EpisodeListModels {
    final class DisplayModel {
        let comic: Comic

        init(comic: Comic) {
            self.comic = comic
        }
    }
}
