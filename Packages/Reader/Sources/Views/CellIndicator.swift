//
//  CellIndicator.swift
//  Reader
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import Kingfisher

@MainActor struct CellIndicator: @preconcurrency Indicator {
    let label = UILabel(frame: .zero)
        .setup(\.font, value: .preferredFont(forTextStyle: .extraLargeTitle))
        .setup(\.textAlignment, value: .center)
        .setup(\.text, value: "Loading...")

    var view: IndicatorView {
        label
    }

    func startAnimatingView() {
        label.isHidden = false
    }

    func stopAnimatingView() {
        label.isHidden = true
    }
}
