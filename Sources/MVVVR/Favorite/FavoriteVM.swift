//
//  FavoriteVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import UIKit

final class FavoriteVM {
    @Published var state = FavoriteModels.State.none
    let model = FavoriteModels.DisplayModel()
}

// MARK: - Public

extension FavoriteVM {
    func doAction(_ action: FavoriteModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case let .removeFavorite(comic):
            actionRemoveFavorite(comic)
        }
    }
}

// MARK: - Private

private extension FavoriteVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getFavoriteList()
            state = .dataLoaded(comics: comics)
        }
    }

    func actionRemoveFavorite(_ comic: Comic) {
        comic.favorited = false
        actionLoadCache()
    }
}
