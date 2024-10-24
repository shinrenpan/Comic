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
        var state = State.none
        let parser = Parser(parserConfiguration: .update())
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadCache:
                actionLoadCache()
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

        private func actionLoadCache() {
            Task {
                let comics = await DBWorker.shared.getComicList()
                let response = CacheLoadedResponse(comics: comics)
                state = .cacheLoaded(response: response)
            }
        }

        private func actionLoadRemote() {
            Task {
                do {
                    let result = try await parser.result()
                    let array = AnyCodable(result).anyArray ?? []
                    await DBWorker.shared.insertOrUpdateComics(array)
                    let comics = await DBWorker.shared.getComicList()
                    let response = RemoteLoadedResponse(comics: comics)
                    state = .remoteLoaded(response: response)
                }
                catch {
                    let comics = await DBWorker.shared.getComicList()
                    let response = RemoteLoadedResponse(comics: comics)
                    state = .remoteLoaded(response: response)
                }
            }
        }

        private func actionLocalSearch(request: LocalSearchRequest) {
            Task {
                let comics = await DBWorker.shared.getComicListByKeywords(request.keywords)
                let response = LocalSearchedResponse(comics: comics)
                state = .localSearched(response: response)
            }
        }

        private func actionAddFavorite(request: AddFavoriteRequest) {
            let comic = request.comic
            comic.favorited = true
            let response = FavoriteAddedResponse(comic: comic)
            state = .favoriteAdded(response: response)
        }

        private func actionRemoveFavorite(request: RemoveFavoriteRequest) {
            let comic = request.comic
            comic.favorited = false
            let response = FavoriteRemovedResponse(comic: comic)
            state = .favoriteRemoved(response: response)
        }
    }
}
