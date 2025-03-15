//
//  ParserConfiguration+Extensions.swift
//
//  Created by Shinren Pan on 2024/6/2.
//

import UIKit
import WebParser

public extension ParserConfiguration {
    static func detail(comicId: String) -> Self {
        let uri = "https://m.manhuagui.com/comic/" + comicId
        let urlComponents = URLComponents(string: uri)!

        return .init(
            request: .init(url: urlComponents.url!),
            windowSize: .init(width: 414, height: 896),
            customUserAgent: .UserAgent.iOS.value,
            retryCount: 30,
            retryDuration: 1,
            javascript: .JavaScript.detail.value
        )
    }

    static func images(comicId: String, episodeId: String) -> Self {
        let uri = "https://tw.manhuagui.com/comic/\(comicId)/\(episodeId).html"
        let urlComponents = URLComponents(string: uri)!

        return .init(
            request: .init(url: urlComponents.url!),
            windowSize: .init(width: 1920, height: 1080),
            customUserAgent: .UserAgent.safari.value,
            retryCount: 30,
            retryDuration: 1,
            javascript: .JavaScript.images.value
        )
    }

    static func update() -> Self {
        let uri = "https://tw.manhuagui.com/update/"
        let urlComponents = URLComponents(string: uri)!

        return .init(
            request: .init(url: urlComponents.url!),
            windowSize: .init(width: 1920, height: 1080),
            customUserAgent: .UserAgent.safari.value,
            retryCount: 30,
            retryDuration: 1,
            javascript: .JavaScript.update.value
        )
    }
    
    static func search(keywords: String, page: Int) -> Self {
        let uri = "https://tw.manhuagui.com/s/\(keywords)_p\(page).html"
        let urlComponents = URLComponents(string: uri)!

        return .init(
            request: .init(url: urlComponents.url!),
            windowSize: .init(width: 1920, height: 1080),
            customUserAgent: .UserAgent.safari.value,
            retryCount: 30,
            retryDuration: 1,
            javascript: .JavaScript.search.value
        )
    }
}
