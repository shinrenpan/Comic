//
//  EpisodeListModels.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

protocol EpisodeListDelegate: UIViewController {
    func list(_ list: EpisodeListVC, selected episode: Comic.Episode)
}

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
        case dataLoaded(episodes: [Comic.Episode], watchedId: String?)
    }
}

// MARK: - Other Model for DisplayModel

extension EpisodeListModels {
    typealias DataSource = UITableViewDiffableDataSource<Section, Comic.Episode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic.Episode>

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
