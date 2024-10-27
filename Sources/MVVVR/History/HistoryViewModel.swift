//
//  HistoryListVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Observation
import UIKit

extension History {
    @Observable final class ViewModel {
        var state = State.none
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadCache:
                actionLoadCache()
            case let .addFavorite(request):
                actionAddFavorite(request: request)
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            case let .removeHistory(request):
                actionRemoveHistory(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadCache() {
            Task {
                let comics = await DBWorker.shared.getComicHistoryList()
                state = .cacheLoaded(response: .init(comics: comics))
            }
        }

        private func actionAddFavorite(request: AddFavoriteRequest) {
            let comic = request.comic
            comic.favorited = true
            state = .favoriteAdded(response: .init(comic: comic))
        }

        private func actionRemoveFavorite(request: RemoveFavoriteRequest) {
            let comic = request.comic
            comic.favorited = false
            state = .favoriteRemoved(response: .init(comic: comic))
        }

        private func actionRemoveHistory(request: RemoveHistoryRequest) {
            Task {
                let comic = request.comic
                await DBWorker.shared.removeComicHistory(comic)
                state = .historyRemoved(response: .init(comic: comic))
            }
        }
    }
}
