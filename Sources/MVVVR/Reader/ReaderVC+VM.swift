//
//  ReaderVC+VM.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension ReaderVC {
    @MainActor
    @Observable
    final class VM {
        let comicId: String
        private(set) var episodeId: String
        private(set) var state = State.none
        private(set) var imageDatas: [ImageData] = []
        private let parser: Parser
        
        init(comicId: String, episodeId: String) {
            self.comicId = comicId
            self.episodeId = episodeId
            self.parser = .init(parserConfiguration: .images(comicId: comicId, episodeId: episodeId))
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case let .loadData(request):
                actionLoadData(request: request)
            case .updateFavorite:
                actionUpdateFavorite()
            case .loadPrev:
                actionLoadPrev()
            case .loadNext:
                actionLoadNext()
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData(request: LoadDataRequest) {
            if let episodeId = request.epidoseId {
                self.episodeId = episodeId
            }
            
            parser.parserConfiguration.request = makeParseRequest()
            
            Task {
                do {
                    let isFavorited = await ComicWorker.shared.getComic(id: comicId)?.favorited ?? false
                    state = .checkoutFavorited(response: .init(isFavorited: isFavorited))
                    
                    let result = try await parser.anyResult()
                    imageDatas = try await makeImagesWithParser(result: result)
                    
                    if imageDatas.isEmpty {
                        state = .dataLoadFail(response: .init(error: .empty))
                    }
                    else {
                        let title = await getCurrentEpisode()?.title
                        let prevEpisodeId = await getPrevEpisodeId()
                        let nextEpisodeId = await getNextEpisodeId()
                        
                        let response = DataLoadedResponse(
                            episodeTitle: title,
                            hasPrev: prevEpisodeId != nil,
                            hasNext: nextEpisodeId != nil
                        )
                        state = .dataLoaded(response: response)
                    }
                }
                catch {
                    state = .dataLoadFail(response: .init(error: .parseFail))
                }
            }
        }

        private func actionUpdateFavorite() {
            Task {
                let comic = await ComicWorker.shared.getComic(id: comicId)
                comic?.favorited.toggle()
                let isFavorite = comic?.favorited ?? false
                state = .checkoutFavorited(response: .init(isFavorited: isFavorite))
            }
        }
        
        private func actionLoadPrev() {
            Task {
                guard let prevEpisodeId = await getPrevEpisodeId() else {
                    state = .dataLoadFail(response: .init(error: .noPrev))
                    return
                }

                actionLoadData(request: .init(epidoseId: prevEpisodeId))
            }
        }

        private func actionLoadNext() {
            Task {
                guard let nextEpisodeId = await getNextEpisodeId() else {
                    state = .dataLoadFail(response: .init(error: .noNext))
                    return
                }
                
                actionLoadData(request: .init(epidoseId: nextEpisodeId))
            }
        }
        
        // MARK: - Make Something

        private func makeImagesWithParser(result: Any) async throws -> [ImageData] {
            let array = AnyCodable(result).anyArray ?? []

            let result: [ImageData] = array.compactMap {
                guard let uri = $0["uri"].string, !uri.isEmpty else {
                    return nil
                }

                guard let uriDecode = uri.removingPercentEncoding else {
                    return nil
                }

                return .init(uri: uriDecode)
            }

            if result.isEmpty {
                throw LoadImageError.empty
            }
            
            await ComicWorker.shared.updateHistory(comicId: comicId, episodeId: episodeId)
            
            return result
        }
        
        private func makeParseRequest() -> URLRequest {
            let uri = "https://tw.manhuagui.com/comic/\(comicId)/\(episodeId).html"
            let urlComponents = URLComponents(string: uri)!

            return .init(url: urlComponents.url!)
        }
        
        // MARK: - Get Something
        
        private func getCurrentEpisode() async -> Database.Episode? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            return episodes.first(where: { $0.id == episodeId })
        }
        
        private func getPrevEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex + 1 })?.id
        }
        
        private func getNextEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex - 1 })?.id
        }
    }
}
