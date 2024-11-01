//
//  UpdateListVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension Update {
    @Observable final class ViewModel {
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
            case let .addFavorite(request):
                actionAddFavorite(request: request)
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getAll()
                let response = DataLoadedResponse(comics: comics.compactMap { .init(comic: $0) })
                state = .dataLoaded(response: response)
            }
        }

        private func actionLoadRemote() {
            Task {
                do {
                    let result = try await parser.result()
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

        private func actionAddFavorite(request: AddFavoriteRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.updateFavorite(id: comic.id, favorited: true)
                actionLoadData()
            }
        }

        private func actionRemoveFavorite(request: RemoveFavoriteRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.updateFavorite(id: comic.id, favorited: false)
                actionLoadData()
            }
        }
    }
}
