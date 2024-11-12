//
//  FavoriteVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Observation
import UIKit

extension Favorite {
    @MainActor
    @Observable
    final class VM {
        private(set) var state = State.none
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getFavorites()
                let response = DataLoadedResponse(comics: comics.compactMap {.init(comic: $0) })
                state = .dataLoaded(response: response)
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
