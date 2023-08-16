//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Reader {
    enum Models {}
}

// MARK: - Action

extension Reader.Models {
    enum Action {
        case loadData
    }
}

// MARK: - State

extension Reader.Models {
    enum State {
        case none
        case showLoading
        case hideLoading
        case showError(message: String)
        case loadedData
    }
}

// MARK: - Display Model

extension Reader.Models {}
