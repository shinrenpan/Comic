//
//  SearchListVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Combine
import UIKit

final class SearchListVM {
    @Published var state = SearchListModels.State.none
    let model = SearchListModels.DisplayModel()
}

// MARK: - Public

extension SearchListVM {
    func doAction(_ action: SearchListModels.Action) {
        switch action {
        case let .search(keywords):
            actionSearch(keywords: keywords)
        case let .updateFavorite(comic):
            actionUpdateFavorite(comic: comic)
        }
    }
}

// MARK: - Private

private extension SearchListVM {
    // MARK: Do Action

    func actionSearch(keywords: String?) {
        guard let keywords else {
            state = .dataLoaded(comics: [])
            return
        }

        Task {
            let comics = await DBWorker.shared.getSearchList(keywords: keywords)
            state = .dataLoaded(comics: comics)
        }
    }

    func actionUpdateFavorite(comic: Comic) {
        comic.favorited.toggle()
        state = .dataUpdated(comic: comic)
    }
}
