//
//  FavoriteListVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Observation
import UIKit

extension Favorite {
    @Observable final class ViewModel {
        var state = State.none
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadCache:
                actionLoadCache()
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadCache() {
            Task {
                let comics = await DBWorker.shared.getComicFavoriteList()
                state = .cacheLoaded(response: .init(comics: comics))
            }
        }

        private func actionRemoveFavorite(request: RemoveFavoriteRequest) {
            let comic = request.comic
            comic.favorited = false
            state = .favoriteRemoved(response: .init(comic: comic))
        }
    }
}
