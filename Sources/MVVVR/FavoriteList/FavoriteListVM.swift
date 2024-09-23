//
//  FavoriteListVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Combine
import UIKit

final class FavoriteListVM: ObservableObject {
    @Published var state = FavoriteListModel.State.none
}

// MARK: - Public

extension FavoriteListVM {
    func doAction(_ action: FavoriteListModel.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case let .removeFavorite(request):
            actionRemoveFavorite(request: request)
        }
    }
}

// MARK: - Private

private extension FavoriteListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicFavoriteList()
            state = .cacheLoaded(response: .init(comics: comics))
        }
    }

    func actionRemoveFavorite(request: FavoriteListModel.RemoveFavoriteRequest) {
        let comic = request.comic
        comic.favorited = false
        state = .favoriteRemoved(response: .init(comic: comic))
    }
}
