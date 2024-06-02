//
//  UpdateVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class UpdateVM {
    @Published var state = UpdateModels.State.none
    let model = UpdateModels.DisplayModel()
    let parser: Parser

    init() {
        self.parser = .init(parserConfiguration: model.parserSetting)
    }
}

// MARK: - Public

extension UpdateVM {
    func doAction(_ action: UpdateModels.Action) {
        switch action {
        case .loadCache:
            actionLoadCache()
        case .loadData:
            actionLoadData()
        case let .updateFavorite(comic):
            actionUpdateFavorite(comic)
        }
    }
}

// MARK: - Private

private extension UpdateVM {
    // MARK: Do Action

    func actionLoadCache() {
        Task {
            let comics = await DBWorker.shared.getAll()
            state = .dataLoaded(comics: comics)
        }
    }

    func actionLoadData() {
        Task {
            do {
                let result = try await parser.start()
                let array = AnyCodable(result).anyArray ?? []
                await DBWorker.shared.insertOrUpdate(array)
                actionLoadCache()
            }
            catch {
                actionLoadCache()
            }
        }
    }

    func actionUpdateFavorite(_ comic: Comic) {
        comic.favorited.toggle()
        state = .dataUpdated(comic: comic)
    }
}
