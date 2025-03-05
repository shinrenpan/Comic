//
//  ViewModel.swift
//  Detail
//
//  Created by Joe Pan on 2025/3/5.
//

import Foundation
import WebParser
import DataBase
import AnyCodable

@MainActor @Observable final class ViewModel {
    let comicId: String
    private(set) var state = State.none
    private let parser: Parser
    
    init(comicId: String) {
        self.comicId = comicId
        self.parser = .init(parserConfiguration: .detail(comicId: comicId))
    }
}

// MARK: - Internal

extension ViewModel {
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
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData() {
        Task {
            if let comic = await DataBase.Storage.shared.getComic(id: comicId) {
                let episodes = await DataBase.Storage.shared.getEpisodes(comicId: comicId)
                
                let displayEpisodes: [Episode] = episodes.compactMap {
                    let selected = comic.watchedId == $0.id
                    return .init(episode: $0, selected: selected)
                }
                
                let displayComic = Comic(comic: comic)
                let response = DataLoadedResponse(comic: displayComic, episodes: displayEpisodes)
                state = .dataLoaded(response: response)
            }
            else {
                state = .dataLoaded(response: .init(comic: nil, episodes: []))
            }
        }
    }

    func actionLoadRemote() {
        Task {
            do {
                guard let comic = await DataBase.Storage.shared.getComic(id: comicId) else {
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

    func actionTapFavorite() {
        Task {
            await DataBase.Storage.shared.getComic(id: comicId)?.favorited.toggle()
            actionLoadData()
        }
    }

    func handleLoadRemote(comic: DataBase.Comic, result: Any) async {
        let data = AnyCodable(result)
        comic.detail?.author = data["author"].string ?? ""
        comic.detail?.desc = data["desc"].string ?? ""

        let array = data["episodes"].anyArray ?? []

        let episodes: [DataBase.Episode] = array.compactMap {
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

        await DataBase.Storage.shared.updateEpisodes(id: comic.id, episodes: episodes)
    }
}
