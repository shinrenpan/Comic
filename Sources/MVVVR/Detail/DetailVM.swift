//
//  DetailVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import AnyCodable
import Combine
import UIKit
import WebParser

final class DetailVM {
    @Published var state = DetailModels.State.none
    let model: DetailModels.DisplayModel
    let parser: Parser

    init(comic: Comic) {
        self.model = .init(comic: comic)
        self.parser = .init(parserConfiguration: model.parserSetting)
    }
}

// MARK: - Public

extension DetailVM {
    func doAction(_ action: DetailModels.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case .updateFavorite:
            actionUpdateFavorite()
        }
    }
}

// MARK: - Private

private extension DetailVM {
    // MARK: Do Action

    func actionLoadData() {
        Task {
            do {
                let result = try await parser.start()
                await handleLoadData(result)
                state = .dataLoaded
            }
            catch {
                state = .dataLoaded
            }
        }
    }

    func actionUpdateFavorite() {
        Task {
            model.comic.favorited.toggle()
            state = .dataLoaded
        }
    }

    // MARK: - Handle Action

    func handleLoadData(_ result: Any) async {
        let data = AnyCodable(result)
        model.comic.detail?.author = data["author"].string ?? ""
        model.comic.detail?.desc = data["desc"].string ?? ""

        let array = data["episodes"].anyArray ?? []

        let episodes: [Comic.Episode] = array.compactMap {
            guard let id = $0["id"].string, !id.isEmpty else {
                return nil
            }

            guard let title = $0["title"].string, !title.isEmpty else {
                return nil
            }

            guard let index = $0["index"].int else {
                return nil
            }

            return .init(id: id, index: index, title: title)
        }

        await DBWorker.shared.updateEpisodes(comic: model.comic, episodes: episodes)

        model.reloadEpisodes()
    }
}
