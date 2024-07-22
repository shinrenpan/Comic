//
//  EpisodeListModels.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

enum EpisodeListModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, DisplayEpisode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DisplayEpisode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayEpisode>

    /// Delegate for handling selected episode
    protocol SelectedDelegate: UIViewController {
        func episodeList(list: EpisodeListVC, selected episode: Comic.Episode)
    }
}

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
        case dataLoaded(episodes: [DisplayEpisode])
    }
}

// MARK: - Others

extension EpisodeListModels {
    enum Section {
        case main
    }

    final class DisplayEpisode: NSObject {
        let data: Comic.Episode
        let selected: Bool

        init(data: Comic.Episode, selected: Bool) {
            self.data = data
            self.selected = selected
        }
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
