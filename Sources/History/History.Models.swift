//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension History {
    enum Models {}
}

// MARK: - Action

extension History.Models {
    enum Action {
        case loadData
        case removeHistory(comic: Comic.Models.DisplayComic)
        case removeAll
    }
}

// MARK: - State

extension History.Models {
    enum State {
        case none
        case loadedData
    }
}

// MARK: - Display Model

extension Favorite.Models {}
