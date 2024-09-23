//
//  EpisodeListVM.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import Combine
import UIKit

final class EpisodeListVM: ObservableObject {
    @Published var state = EpisodeListModel.State.none
    let comic: Comic

    init(comic: Comic) {
        self.comic = comic
    }
}

// MARK: - Public

extension EpisodeListVM {
    func doAction(_ action: EpisodeListModel.Action) {
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
        // comic.episodes 無排序, 需要先排序
        let episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

        let displayEpisodes: [EpisodeListModel.Episode] = episodes.compactMap {
            let selected = comic.watchedId == $0.id
            return .init(data: $0, selected: selected)
        }

        state = .dataLoaded(response: .init(episodes: displayEpisodes))
    }
}
