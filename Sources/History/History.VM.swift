//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension History {
    final class VM {
        @Published var state = History.Models.State.none
        let historyWorkey = HistoryWorker()
        let favoriteWorker = FavoriteWorker()
        var comics: [Comic.Models.DisplayComic] = []
    }
}

// MARK: - Do Action

extension History.VM {
    func doAction(_ action: History.Models.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case let .removeHistory(comic):
            actionRemoveHistory(comic: comic)
        case .removeAll:
            actionRemoveAll()
        }
    }
}

// MARK: - Handle Action

private extension History.VM {
    func actionLoadData() {
        comics = historyWorkey.comics
        comics.forEach { $0.isFavorite = favoriteWorker.isFavorite(comic: $0) }
        state = .loadedData
    }
    
    func actionRemoveHistory(comic: Comic.Models.DisplayComic) {
        historyWorkey.removeWatched(comic: comic)
        comics = historyWorkey.comics
        state = .loadedData
    }
    
    func actionRemoveAll() {
        historyWorkey.removeAll()
        comics = historyWorkey.comics
        state = .loadedData
    }
}

// MARK: - Response Action

private extension History.VM {}

// MARK: - Convert Something

private extension Favorite.VM {}
