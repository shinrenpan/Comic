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
    @Published var state = ReaderModel.State.none
    let comic: Comic
    var currentEpisode: Comic.Episode
    let parser: Parser
    var imageDatas: [ReaderModel.ImageData] = []
    
    init(comic: Comic, episode: Comic.Episode) {
        self.comic = comic
        self.currentEpisode = episode
        self.parser = .init(parserConfiguration: .images(comic: comic, episode: episode))
    }
}

// MARK: - Public

extension ReaderVM {
    func doAction(_ action: ReaderModel.Action) {
        switch action {
        case let .loadData(request):
            actionLoadData(request: request)
        case .loadPrev:
            actionLoadPrev()
        case .loadNext:
            actionLoadNext()
        }
    }
}

// MARK: - Private

private extension ReaderVM {
    // MARK: Do Action

    func actionLoadData(request: ReaderModel.LoadDataRequest) {
        if let epidose = request.epidose {
            currentEpisode = epidose
        }
        
        parser.parserConfiguration.request = makeParseRequest()
        
        Task {
            do {
                let result = try await parser.result()
                let images = try await makeImagesWithParser(result: result)
                imageDatas = images.compactMap { .init(uri: $0.uri) }
                
                if imageDatas.isEmpty {
                    state = .dataLoadFail(response: .init(error: .empty))
                }
                else {
                    let response = ReaderModel.DataLoadedResponse(
                        episode: currentEpisode,
                        hasPrev: getPrevEpidose() != nil,
                        hasNext: getNextEpisode() != nil
                    )
                    state = .dataLoaded(response: response)
                }
            }
            catch {
                state = .dataLoadFail(response: .init(error: .parseFail))
            }
        }
    }

    func actionLoadPrev() {
        guard let prevEpisode = getPrevEpidose() else {
            state = .dataLoadFail(response: .init(error: .noPrev))
            return
        }
        
        actionLoadData(request: .init(epidose: prevEpisode))
    }

    func actionLoadNext() {
        guard let nextEpisode = getNextEpisode() else {
            state = .dataLoadFail(response: .init(error: .noNext))
            return
        }
        
        actionLoadData(request: .init(epidose: nextEpisode))
    }

    // MARK: - Make Something

    func makeImagesWithParser(result: Any) async throws -> [Comic.ImageData] {
        let array = AnyCodable(result).anyArray ?? []

        let result: [Comic.ImageData] = array.compactMap {
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

        if result.isEmpty {
            throw ReaderModel.LoadImageError.empty
        }
        
        await DBWorker.shared.addComicHistory(comic, episode: currentEpisode)
        
        return result
    }
    
    func makeParseRequest() -> URLRequest {
        let uri = "https://tw.manhuagui.com/comic/\(comic.id)/\(currentEpisode.id).html"
        let urlComponents = URLComponents(string: uri)!

        return .init(url: urlComponents.url!)
    }
    
    // MARK: - Get Something
    
    func getPrevEpidose() -> Comic.Episode? {
        comic.episodes?.first(where: { $0.index == currentEpisode.index + 1 })
    }
    
    func getNextEpisode() -> Comic.Episode? {
        comic.episodes?.first(where: { $0.index == currentEpisode.index - 1 })
    }
}
