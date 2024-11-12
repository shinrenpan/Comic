//
//  UpdateVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension Update {
    @MainActor
    @Observable
    final class VM {
        private(set) var state = State.none
        private let parser = Parser(parserConfiguration: .update())
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                actionLoadRemote()
            case let .localSearch(request):
                actionLocalSearch(request: request)
            case let .changeFavorite(request):
                actionChangeFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getAll(fetchLimit: 1000)
                let response = DataLoadedResponse(comics: comics.compactMap { .init(comic: $0) })
                state = .dataLoaded(response: response)
            }
        }

        private func actionLoadRemote() {
            Task {
                do {
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? [] 
                    await ComicWorker.shared.insertOrUpdateComics(array)
                    actionLoadData()
                }
                catch {
                    actionLoadData()
                }
            }
        }

        private func actionLocalSearch(request: LocalSearchRequest) {
            Task {
                let comics = await ComicWorker.shared.getAll(keywords: request.keywords)
                let response = LocalSearchedResponse(comics: comics.compactMap { .init(comic: $0) })
                state = .localSearched(response: response)
            }
        }

        private func actionChangeFavorite(request: ChangeFavoriteRequest) {
            Task {
                let comic = request.comic
                
                if let result = await ComicWorker.shared.updateFavorite(id: comic.id, favorited: !comic.favorited) {
                    let response = FavoriteChangedResponse(comic: .init(comic: result))
                    state = .favoriteChanged(response: response)
                }
            }
        }
    }
}
