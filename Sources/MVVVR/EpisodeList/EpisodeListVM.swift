//
//  EpisodeListVM.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import Combine
import UIKit

final class EpisodeListVM {
    @Published var state = EpisodeListModels.State.none
    let model: EpisodeListModels.DisplayModel

    init(comic: Comic) {
        self.model = .init(comic: comic)
    }
}

// MARK: - Public

extension EpisodeListVM {
    func doAction(_ action: EpisodeListModels.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        }
    }
}

// MARK: - Private

private extension EpisodeListVM {
    // MARK: Do Action

    func actionLoadData() {
        let episodes = model.comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

        let response = EpisodeListModels.State.DataLoadedResponse(
            episodes: episodes,
            watchId: model.comic.watchedId
        )

        state = .dataLoaded(response: response)
    }
}
