//
//  HistoryListVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import UIKit

final class HistoryListVM: ObservableObject {
    @Published var state = HistoryListModel.State.none
}

// MARK: - Public

extension HistoryListVM {
    func doAction(_ action: HistoryListModel.Action) {
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
}

// MARK: - Private

private extension HistoryListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicHistoryList()
            state = .cacheLoaded(response: .init(comics: comics))
        }
    }

    func actionAddFavorite(request: HistoryListModel.AddFavoriteRequest) {
        let comic = request.comic
        comic.favorited = true
        state = .favoriteAdded(response: .init(comic: comic))
    }

    func actionRemoveFavorite(request: HistoryListModel.RemoveFavoriteRequest) {
        let comic = request.comic
        comic.favorited = false
        state = .favoriteRemoved(response: .init(comic: comic))
    }

    func actionRemoveHistory(request: HistoryListModel.RemoveHistoryRequest) {
        Task {
            let comic = request.comic
            await DBWorker.shared.removeComicHistory(comic)
            state = .historyRemoved(response: .init(comic: comic))
        }
    }
}
