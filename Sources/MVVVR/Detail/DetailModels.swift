//
//  DetailModels.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit
import WebParser

enum DetailModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, DisplayEpisode>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, DisplayEpisode>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayEpisode>
}

// MARK: - Action

extension DetailModels {
    enum Action {
        case loadCache
        case loadRemote
        case tapFavorite
    }
}

// MARK: - State

extension DetailModels {
    enum State {
        case none
        case cacheLoaded(episodes: [DisplayEpisode])
        case remoteLoaded(episodes: [DisplayEpisode])
        case favoriteUpdated
    }
}

// MARK: - Other Model for DisplayModel

extension DetailModels {
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

extension DetailModels {
    final class DisplayModel {
        let comic: Comic

        init(comic: Comic) {
            self.comic = comic
        }
    }
}
