//
//  HistoryListVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import UIKit

final class HistoryListVM {
    @Published var state = HistoryListModels.State.none
    let model = HistoryListModels.DisplayModel()
}

// MARK: - Public

extension HistoryListVM {
    func doAction(_ action: HistoryListModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case let .addFavorite(comic):
            actionAddFavorite(comic: comic)
        case let .removeFavorite(comic):
            actionRemoveFavorite(comic: comic)
        case let .removeHistory(comic):
            actionRemoveHistory(comic: comic)
        }
    }
}

// MARK: - Private

private extension HistoryListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicHistoryList()
            state = .cacheLoaded(comics: comics)
        }
    }

    func actionAddFavorite(comic: Comic) {
        comic.favorited = true
        state = .favoriteAdded(comic: comic)
    }

    func actionRemoveFavorite(comic: Comic) {
        comic.favorited = false
        state = .favoriteRemoved(comic: comic)
    }

    func actionRemoveHistory(comic: Comic) {
        Task {
            await DBWorker.shared.removeComicHistory(comic)
            state = .historyRemoved(comic: comic)
        }
    }
}
