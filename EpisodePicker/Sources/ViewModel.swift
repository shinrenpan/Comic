//
//  ViewModel.swift
//  EpisodePicker
//
//  Created by Joe Pan on 2025/3/5.
//

import Observation
import DataBase

@MainActor @Observable final class ViewModel {
    private(set) var state = State.none
    private let comicId: String
    private let epidoseId: String
    
    init(comicId: String, epidoseId: String) {
        self.comicId = comicId
        self.epidoseId = epidoseId
    }
}

// MARK: - Internal

extension ViewModel {
    func doAction(_ action: Action) {
        switch action {
        case .loadData:
            actionLoadData()
        }
    }
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData() {
        Task {
            let episodes = await DataBase.Storage.shared.getEpisodes(comicId: comicId)
            
            let displayEpisodes: [Episode] = episodes.compactMap {
                let selected = epidoseId == $0.id
                return .init(epidose: $0, selected: selected)
            }
            
            state = .dataLoaded(response: .init(episodes: displayEpisodes))
        }
    }
}
