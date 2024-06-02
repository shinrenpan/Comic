//
//  HistoryVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import UIKit

final class HistoryVM {
    @Published var state = HistoryModels.State.none
    let model = HistoryModels.DisplayModel()
}

// MARK: - Public

extension HistoryVM {
    func doAction(_ action: HistoryModels.Action) {
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

private extension HistoryVM {
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
