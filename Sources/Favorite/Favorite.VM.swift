//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension Favorite {
    final class VM {
        @Published var state = Favorite.Models.State.none
        let favoriteWorker = FavoriteWorker()
        var comics: [Comic.Models.DisplayComic] = []
    }
}

// MARK: - Do Action

extension Favorite.VM {
    func doAction(_ action: Favorite.Models.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case let .removeComic(comic):
            actionRemoveComic(comic: comic)
        case .removeAll:
            actionRemoveAll()
        }
    }
}

// MARK: - Handle Action

private extension Favorite.VM {
    func actionLoadData() {
        comics = favoriteWorker.comics
        state = .loadedData
    }
    
    func actionRemoveComic(comic: Comic.Models.DisplayComic) {
        favoriteWorker.removeFavorite(comic: comic)
        comics = favoriteWorker.comics
        state = .loadedData
    }
    
    func actionRemoveAll() {
        favoriteWorker.removeAll()
        comics = favoriteWorker.comics
        state = .loadedData
    }
}

// MARK: - Response Action

private extension Favorite.VM {}

// MARK: - Convert Something

private extension Favorite.VM {}
