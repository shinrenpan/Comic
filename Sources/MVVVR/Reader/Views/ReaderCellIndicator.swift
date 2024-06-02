//
//  ReaderCellIndicator.swift
//
//  Created by Shinren Pan on 2024/5/31.
//

import Kingfisher
import UIKit

struct ReaderCellIndicator: Indicator {
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
