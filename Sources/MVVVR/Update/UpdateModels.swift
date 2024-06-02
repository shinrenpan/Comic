//
//  UpdateModels.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

enum UpdateModels {}

// MARK: - Action

extension UpdateModels {
    enum Action {
        case loadCache
        case loadData
        case updateFavorite(comic: Comic)
    }
}

// MARK: - State

extension UpdateModels {
    enum State {
        case none
        case dataLoaded(comics: [Comic])
        case dataUpdated(comic: Comic)
    }
}

// MARK: - Other Model for DisplayModel

extension UpdateModels {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Comic>
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Comic>

    enum Section {
        case main
    }
}

// MARK: - Display Model for ViewModel

extension UpdateModels {
    final class DisplayModel {
        let parserSetting: ParserConfiguration

        init() {
            let uri = "https://www.manhuagui.com/update/"
            let urlComponents = URLComponents(string: uri)!

            self.parserSetting = .init(
                request: .init(url: urlComponents.url!),
                windowSize: .init(width: 1920, height: 1080),
                customUserAgent: .UserAgent.safari.value,
                retryCount: 30,
                retryDuration: 1,
                javascript: .JavaScript.update.value
            )
        }
    }
}
