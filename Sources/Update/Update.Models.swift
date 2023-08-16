//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Update {
    enum Models {}
}

// MARK: - Action

extension Update.Models {
    enum Action {
        case loadData
        case addFavorite(comic: Comic.Models.DisplayComic)
        case removeFavorite(comic: Comic.Models.DisplayComic)
        case checkFavorite
    }
}

// MARK: - State

extension Update.Models {
    enum State {
        case none
        case showLoading
        case hideLoading
        case showError(message: String)
        case loadedData
        case addFavorite
        case removeFavorite
    }
}

// MARK: - Display Model

extension Update.Models {}
