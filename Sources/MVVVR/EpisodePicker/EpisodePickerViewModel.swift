//
//  EpisodeListVM.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import Observation
import UIKit

extension EpisodePicker {
    @Observable final class ViewModel {
        var state = State.none
        let comic: Comic
        
        init(comic: Comic) {
            self.comic = comic
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            // comic.episodes 無排序, 需要先排序
            let episodes = comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []

            let displayEpisodes: [Episode] = episodes.compactMap {
                let selected = comic.watchedId == $0.id
                return .init(data: $0, selected: selected)
            }

            state = .dataLoaded(response: .init(episodes: displayEpisodes))
        }
    }
}
