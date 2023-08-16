//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Favorite {
    enum Models {}
}

// MARK: - Action

extension Favorite.Models {
    enum Action {
        case loadData
        case removeComic(comic: Comic.Models.DisplayComic)
        case removeAll
    }
}

// MARK: - State

extension Favorite.Models {
    enum State {
        case none
        case loadedData
    }
}

// MARK: - Display Model

extension Favorite.Models {}
