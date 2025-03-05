//
//  ViewModel.swift
//  History
//
//  Created by Joe Pan on 2025/3/5.
//

import Observation
import DataBase

@MainActor @Observable final class ViewModel {
    private(set) var state = State.none
}

// MARK: - Internal

extension ViewModel {
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
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData() {
        Task {
            let comics = await DataBase.Storage.shared.getHistories()
            let response = DataLoadedResponse(comics: comics.compactMap { .init(comic: $0) })
            state = .dataLoaded(response: response)
        }
    }

    func actionAddFavorite(request: AddFavoriteRequest) {
        Task {
            let comic = request.comic
            await DataBase.Storage.shared.updateFavorite(id: comic.id, favorited: true)
            actionLoadData()
        }
    }

    func actionRemoveFavorite(request: RemoveFavoriteRequest) {
        Task {
            let comic = request.comic
            await DataBase.Storage.shared.updateFavorite(id: comic.id, favorited: false)
            actionLoadData()
        }
    }

    func actionRemoveHistory(request: RemoveHistoryRequest) {
        Task {
            let comic = request.comic
            await DataBase.Storage.shared.removeHistory(id: comic.id)
            actionLoadData()
        }
    }
}
