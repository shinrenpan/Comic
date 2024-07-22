//
//  UpdateListVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class UpdateListVM {
    @Published var state = UpdateListModels.State.none
    let model = UpdateListModels.DisplayModel()
    let parser = Parser(parserConfiguration: .update())
}

// MARK: - Public

extension UpdateListVM {
    func doAction(_ action: UpdateListModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case .loadRemote:
            actionLoadRemote()
        case let .localSearch(keywords):
            actionSearch(keywords: keywords)
        case let .addFavorite(comic):
            actionAddFavorite(comic: comic)
        case let .removeFavorite(comic):
            actionRemoveFavorite(comic: comic)
        }
    }
}

// MARK: - Private

private extension UpdateListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicList()
            state = .cacheLoaded(comics: comics)
        }
    }

    func actionLoadRemote() {
        Task {
            do {
                let result = try await parser.start()
                let array = AnyCodable(result).anyArray ?? []
                await DBWorker.shared.insertOrUpdateComics(array)
                let comics = await DBWorker.shared.getComicList()
                state = .remoteLoaded(comics: comics)
            }
            catch {
                let comics = await DBWorker.shared.getComicList()
                state = .remoteLoaded(comics: comics)
            }
        }
    }

    func actionSearch(keywords: String) {
        Task {
            let comics = await DBWorker.shared.getComicListByKeywords(keywords)
            state = .searchResult(comics: comics)
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
}
