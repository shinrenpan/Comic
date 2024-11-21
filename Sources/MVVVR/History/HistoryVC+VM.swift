//
//  HistoryVC+VM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Observation
import UIKit

extension HistoryVC {
    @MainActor
    @Observable
    final class VM {
        private(set) var state = State.none
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case let .addFavorite(request):
                actionAddFavorite(request: request)
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            case let .removeHistory(request):
                actionRemoveHistory(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getHistories()
                let response = DataLoadedResponse(comics: comics.compactMap { .init(comic: $0) })
                state = .dataLoaded(response: response)
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

        private func actionRemoveHistory(request: RemoveHistoryRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.removeHistory(id: comic.id)
                actionLoadData()
            }
        }
    }
}
