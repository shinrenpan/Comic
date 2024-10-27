//
//  DetailVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension Detail {
    @Observable final class ViewModel {
        var state = State.none
        let comic: Comic
        let parser: Parser
        
        init(comic: Comic) {
            self.comic = comic
            self.parser = .init(parserConfiguration: .detail(comic: comic))
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadCache:
                actionLoadCache()
            case .loadRemote:
                actionLoadRemote()
            case .tapFavorite:
                actionTapFavorite()
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadCache() {
            // comic.episodes 無排序, 需要先排序
            let episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

            let displayEpisodes: [Episode] = episodes.compactMap {
                let selected = comic.watchedId == $0.id
                return .init(data: $0, selected: selected)
            }

            let response = CacheLoadedResponse(comic: comic, episodes: displayEpisodes)
            state = .cacheLoaded(response: response)
        }

        private func actionLoadRemote() {
            Task {
                do {
                    let result = try await parser.result()
                    await handleLoadRemote(result: result)
                    // comic.episodes 無排序, 需要先排序
                    let episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

                    let displayEpisodes: [Episode] = episodes.compactMap {
                        let selected = comic.watchedId == $0.id
                        return .init(data: $0, selected: selected)
                    }

                    let response = RemoteLoadedResponse(comic: comic, episodes: displayEpisodes)
                    state = .remoteLoaded(response: response)
                }
                catch {
                    let response = RemoteLoadedResponse(comic: comic, episodes: [])
                    state = .remoteLoaded(response: response)
                }
            }
        }

        private func actionTapFavorite() {
            Task {
                comic.favorited.toggle()
                state = .favoriteUpdated(response: .init(comic: comic))
            }
        }

        // MARK: - Handle Action Result

        private func handleLoadRemote(result: Any) async {
            let data = AnyCodable(result)
            comic.detail?.author = data["author"].string ?? ""
            comic.detail?.desc = data["desc"].string ?? ""

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

            await DBWorker.shared.updateComicEpisodes(comic, episodes: episodes)
        }
    }
}
