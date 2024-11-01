//
//  EpisodeListVM.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import Observation
import UIKit

extension EpisodePicker {
    @MainActor @Observable final class ViewModel {
        private(set) var state = State.none
        private let comicId: String
        private let epidoseId: String
        
        init(comicId: String, epidoseId: String) {
            self.comicId = comicId
            self.epidoseId = epidoseId
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
            Task {
                let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
                
                let displayEpisodes: [DisplayEpisode] = episodes.compactMap {
                    let selected = epidoseId == $0.id
                    return .init(epidose: $0, selected: selected)
                }
                
                state = .dataLoaded(response: .init(episodes: displayEpisodes))
            }
        }
    }
}
