//
//  Kingfisher+Extensions.swift
//
//  Created by Joe Pan on 2024/10/28.
//

import UIKit
import Kingfisher

public extension Kingfisher.ImageCache {
    func asyncCleanDiskCache() async {
        await withCheckedContinuation { continuation in
            clearDiskCache {
                continuation.resume(returning: ())
            }
        }
    }
}

extension KingfisherManager {
    func asyncRetrieveImage(with resource: Resource, options: KingfisherOptionsInfo? = nil) async throws -> KFCrossPlatformImage {
        try await withCheckedThrowingContinuation { continuation in
            retrieveImage(with: resource, options: options) { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: value.image)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
