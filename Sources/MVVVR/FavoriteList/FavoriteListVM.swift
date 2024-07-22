//
//  FavoriteListVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import UIKit

final class FavoriteListVM {
    @Published var state = FavoriteListModels.State.none
    let model = FavoriteListModels.DisplayModel()
}

// MARK: - Public

extension FavoriteListVM {
    func doAction(_ action: FavoriteListModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case let .removeFavorite(comic):
            actionRemoveFavorite(comic)
        }
    }
}

// MARK: - Private

private extension FavoriteListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicFavoriteList()
            state = .cacheLoaded(comics: comics)
        }
    }

    func actionRemoveFavorite(_ comic: Comic) {
        comic.favorited = false
        state = .favoriteRemoved(comic: comic)
    }
}
