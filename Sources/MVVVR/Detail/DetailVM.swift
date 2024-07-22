//
//  DetailVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class DetailVM {
    @Published var state = DetailModels.State.none
    let model: DetailModels.DisplayModel
    let parser: Parser

    init(comic: Comic) {
        self.model = .init(comic: comic)
        self.parser = .init(parserConfiguration: .detail(comic: comic))
    }
}

// MARK: - Public

extension DetailVM {
    func doAction(_ action: DetailModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case .loadRemote:
            actionLoadRemote()
        case .tapFavorite:
            actionTapFavorite()
        }
    }
}

// MARK: - Private

private extension DetailVM {
    // MARK: Do Action

    func actionLoadCache() {
        // comic.episodes 無排序, 需要先排序
        let episodes = model.comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

        let displayEpisodes: [DetailModels.DisplayEpisode] = episodes.compactMap {
            let selected = model.comic.watchedId == $0.id
            return .init(data: $0, selected: selected)
        }

        state = .cacheLoaded(episodes: displayEpisodes)
    }

    func actionLoadRemote() {
        Task {
            do {
                let result = try await parser.start()
                await handleLoadRemote(result: result)
                // comic.episodes 無排序, 需要先排序
                let episodes = model.comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

                let displayEpisodes: [DetailModels.DisplayEpisode] = episodes.compactMap {
                    let selected = model.comic.watchedId == $0.id
                    return .init(data: $0, selected: selected)
                }

                state = .remoteLoaded(episodes: displayEpisodes)
            }
            catch {
                state = .remoteLoaded(episodes: [])
            }
        }
    }

    func actionTapFavorite() {
        Task {
            model.comic.favorited.toggle()
            state = .favoriteUpdated
        }
    }

    // MARK: - Handle Action

    func handleLoadRemote(result: Any) async {
        let data = AnyCodable(result)
        model.comic.detail?.author = data["author"].string ?? ""
        model.comic.detail?.desc = data["desc"].string ?? ""

        let array = data["episodes"].anyArray ?? []

        let episodes: [Comic.Episode] = array.compactMap {
            guard let id = $0["id"].string, !id.isEmpty else {
                return nil
            }

            guard let title = $0["title"].string, !title.isEmpty else {
                return nil
            }

            guard let index = $0["index"].int else {
                return nil
            }

            return .init(id: id, index: index, title: title)
        }

        await DBWorker.shared.updateComicEpisodes(model.comic, episodes: episodes)
    }
}
