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
    @MainActor @Observable final class ViewModel {
        let comicId: String
        private(set) var state = State.none
        private let parser: Parser
        
        init(comicId: String) {
            self.comicId = comicId
            self.parser = .init(parserConfiguration: .detail(comicId: comicId))
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                actionLoadRemote()
            case .tapFavorite:
                actionTapFavorite()
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            Task {
                if let comic = await ComicWorker.shared.getComic(id: comicId) {
                    let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
                    
                    let displayEpisodes: [DisplayEpisode] = episodes.compactMap {
                        let selected = comic.watchedId == $0.id
                        return .init(episode: $0, selected: selected)
                    }
                    
                    let displayComic = DisplayComic(comic: comic)
                    let response = DataLoadedResponse(comic: displayComic, episodes: displayEpisodes)
                    state = .dataLoaded(response: response)
                }
                else {
                    state = .dataLoaded(response: .init(comic: nil, episodes: []))
                }
            }
        }

        private func actionLoadRemote() {
            Task {
                do {
                    guard let comic = await ComicWorker.shared.getComic(id: comicId) else {
                        throw ParserError.timeout
                    }
                    
                    let result = try await parser.anyResult()
                    await handleLoadRemote(comic: comic, result: result)
                    actionLoadData()
                }
                catch {
                    actionLoadData()
                }
            }
        }

        private func actionTapFavorite() {
            Task {
                await ComicWorker.shared.getComic(id: comicId)?.favorited.toggle()
                actionLoadData()
            }
        }

        // MARK: - Handle Action Result

        private func handleLoadRemote(comic: Comic, result: Any) async {
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

            await ComicWorker.shared.updateEpisodes(id: comic.id, episodes: episodes)
        }
    }
}
