//
//  UpdateListVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class UpdateListVM: ObservableObject {
    @Published var state = UpdateListModel.State.none
    let parser = Parser(parserConfiguration: .update())
}

// MARK: - Public

extension UpdateListVM {
    func doAction(_ action: UpdateListModel.Action) {
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
}

// MARK: - Private

private extension UpdateListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicList()
            let response = UpdateListModel.CacheLoadedResponse(comics: comics)
            state = .cacheLoaded(response: response)
        }
    }

    func actionLoadRemote() {
        Task {
            do {
                let result = try await parser.result()
                let array = AnyCodable(result).anyArray ?? []
                await DBWorker.shared.insertOrUpdateComics(array)
                let comics = await DBWorker.shared.getComicList()
                let response = UpdateListModel.RemoteLoadedResponse(comics: comics)
                state = .remoteLoaded(response: response)
            }
            catch {
                let comics = await DBWorker.shared.getComicList()
                let response = UpdateListModel.RemoteLoadedResponse(comics: comics)
                state = .remoteLoaded(response: response)
            }
        }
    }

    func actionLocalSearch(request: UpdateListModel.LocalSearchRequest) {
        Task {
            let comics = await DBWorker.shared.getComicListByKeywords(request.keywords)
            let response = UpdateListModel.LocalSearchedResponse(comics: comics)
            state = .localSearched(response: response)
        }
    }

    func actionAddFavorite(request: UpdateListModel.AddFavoriteRequest) {
        let comic = request.comic
        comic.favorited = true
        let response = UpdateListModel.FavoriteAddedResponse(comic: comic)
        state = .favoriteAdded(response: response)
    }

    func actionRemoveFavorite(request: UpdateListModel.RemoveFavoriteRequest) {
        let comic = request.comic
        comic.favorited = false
        let response = UpdateListModel.FavoriteRemovedResponse(comic: comic)
        state = .favoriteRemoved(response: response)
    }
}
