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
        case let .removeHistory(comic):
            actionRemoveHistory(comic)
        case let .updateFavorite(comic):
            actionUpdateFavorite(comic: comic)
        }
    }
}

// MARK: - Private

private extension HistoryListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getHistoryList()
            state = .dataLoaded(comics: comics)
        }
    }

    func actionRemoveHistory(_ comic: Comic) {
        Task {
            await DBWorker.shared.removeComicWatched(comic)
            actionLoadCache()
        }
    }

    func actionUpdateFavorite(comic: Comic) {
        comic.favorited.toggle()
        state = .dataUpdated(comic: comic)
    }
}
