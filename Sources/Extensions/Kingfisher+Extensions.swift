//
//  Kingfisher+Extensions.swift
//
//  Created by Joe Pan on 2024/10/28.
//
//

import UIKit
import Kingfisher

extension Kingfisher.ImageCache {
    func asyncCleanDiskCache() async {
        await withCheckedContinuation { continuation in
            ImageCache.default.clearDiskCache {
                continuation.resume(returning: ())
            }
        }
    }
}
