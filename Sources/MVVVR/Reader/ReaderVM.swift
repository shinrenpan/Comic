//
//  ReaderVM.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class ReaderVM {
    @Published var state = ReaderModels.State.none
    let model: ReaderModels.DisplayModel
    let parser: Parser

    init(comic: Comic, episode: Comic.Episode) {
        self.model = .init(comic: comic, episode: episode)
        self.parser = .init(parserConfiguration: model.parserSetting)
    }
}

// MARK: - Public

extension ReaderVM {
    func doAction(_ action: ReaderModels.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case .loadPrev:
            actionLoadPrev()
        case .loadNext:
            actionLoadNext()
        case let .loadEpidoe(episode):
            actionLoadEpisode(episode)
        }
    }
}

// MARK: - Private

private extension ReaderVM {
    // MARK: - Do Action

    func actionLoadData() {
        Task {
            do {
                let result = try await parser.start()
                try await handleLoadData(result)
                state = .dataLoaded
            }
            catch {
                state = .dataLoaded
            }
        }
    }

    func actionLoadPrev() {
        guard let prevEposide = model.prevEpisode else {
            state = .dataLoaded
            return
        }

        parser.parserConfiguration.request = makeNewParserRequest(prevEposide)
        model.currentEpisode = prevEposide

        actionLoadData()
    }

    func actionLoadNext() {
        guard let nextEpisode = model.nextEpisode else {
            state = .dataLoaded
            return
        }

        parser.parserConfiguration.request = makeNewParserRequest(nextEpisode)
        model.currentEpisode = nextEpisode

        actionLoadData()
    }

    func actionLoadEpisode(_ episode: Comic.Episode) {
        parser.parserConfiguration.request = makeNewParserRequest(episode)
        model.currentEpisode = episode

        actionLoadData()
    }

    // MARK: - Handle Action

    func handleLoadData(_ result: Any) async throws {
        let array = AnyCodable(result).anyArray ?? []

        model.images = array.compactMap {
            guard let index = $0["index"].int else {
                return nil
            }

            guard let uri = $0["uri"].string, !uri.isEmpty else {
                return nil
            }

            guard let uriDecode = uri.removingPercentEncoding else {
                return nil
            }

            return .init(index: index, uri: uriDecode)
        }

        if !model.images.isEmpty {
            await DBWorker.shared.addComicWatched(model.comic, episode: model.currentEpisode)
        }
    }

    // MARK: - Make Something

    func makeNewParserRequest(_ episode: Comic.Episode) -> URLRequest {
        let uri = "https://tw.manhuagui.com/comic/\(model.comic.id)/\(episode.id).html"
        let urlComponents = URLComponents(string: uri)!

        return .init(url: urlComponents.url!)
    }
}
