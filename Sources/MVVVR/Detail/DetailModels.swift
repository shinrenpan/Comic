//
//  DetailModels.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit
import WebParser

enum DetailModels {}

// MARK: - Action

extension DetailModels {
    enum Action {
        case loadData
        case updateFavorite
    }
}

// MARK: - State

extension DetailModels {
    enum State {
        case none
        case dataLoaded
    }
}

// MARK: - Other Model for DisplayModel

extension DetailModels {}

// MARK: - Display Model for ViewModel

extension DetailModels {
    final class DisplayModel {
        let comic: Comic
        let parserSetting: ParserConfiguration
        // SwiftData 存的 Array 無排序, 所以再用一個排序
        var episodes: [Comic.Episode]

        init(comic: Comic) {
            self.comic = comic
            self.episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []
            self.parserSetting = .makeParseDetail(comic)
        }

        func reloadEpisodes() {
            episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []
        }
    }
}
