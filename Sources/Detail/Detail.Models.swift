//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Detail {
    enum Models {}
}

// MARK: - Action

extension Detail.Models {
    enum Action {
        case loadData
        case tapFavorite
        case saveHistory(episode: Comic.Models.DisplayEpisode)
    }
}

// MARK: - State

extension Detail.Models {
    enum State {
        case none
        case showLoading
        case hideLoading
        case showError(message: String)
        case loadedData
        case tapFavorite
    }
}

// MARK: - Display Model

extension Detail.Models {}
