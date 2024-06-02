//
//  Collection+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
