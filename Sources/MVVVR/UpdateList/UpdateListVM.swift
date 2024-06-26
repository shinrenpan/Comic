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
        case .loadData:
            actionLoadData()
        case let .localSearch(keywords):
            actionSearch(keywords)
        case let .updateFavorite(comic):
            actionUpdateFavorite(comic)
        }
    }
}

// MARK: - Private

private extension UpdateListVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getComicList()
            state = .dataLoaded(comics: comics)
        }
    }

    func actionLoadData() {
        Task {
            do {
                let result = try await parser.start()
                let array = AnyCodable(result).anyArray ?? []
                await DBWorker.shared.insertOrUpdateComics(array)
                actionLoadCache()
            }
            catch {
                actionLoadCache()
            }
        }
    }

    func actionSearch(_ keywords: String) {
        Task {
            let comics = await DBWorker.shared.getComicListByKeywords(keywords)
            state = .dataLoaded(comics: comics)
        }
    }

    func actionUpdateFavorite(_ comic: Comic) {
        comic.favorited.toggle()
        state = .dataUpdated(comic: comic)
    }
}
