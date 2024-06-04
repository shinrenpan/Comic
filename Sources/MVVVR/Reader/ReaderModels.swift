//
//  ReaderModels.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit
import WebParser

enum ReaderModels {}

// MARK: - Action

extension ReaderModels {
    enum Action {
        case loadData
        case loadPrev
        case loadNext
        case loadEpidoe(_ episode: Comic.Episode)
    }
}

// MARK: - State

extension ReaderModels {
    enum State {
        case none
        case dataLoaded
    }
}

// MARK: - Other Model for DisplayModel

extension ReaderModels {}

// MARK: - Display Model for ViewModel

extension ReaderModels {
    final class DisplayModel {
        let comic: Comic
        var currentEpisode: Comic.Episode
        let parserSetting: ParserConfiguration
        var images: [Comic.ImageData] = []

        var prevEpisode: Comic.Episode? {
            comic.episodes?.first(where: { $0.index == currentEpisode.index + 1 })
        }

        var nextEpisode: Comic.Episode? {
            comic.episodes?.first(where: { $0.index == currentEpisode.index - 1 })
        }

        var hasPrev: Bool {
            prevEpisode != nil
        }

        var hasNext: Bool {
            nextEpisode != nil
        }

        init(comic: Comic, episode: Comic.Episode) {
            self.comic = comic
            self.currentEpisode = episode
            self.parserSetting = .makeParseImages(comic: comic, episode: episode)
        }
    }
}
