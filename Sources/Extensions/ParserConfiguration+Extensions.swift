//
//  ParserConfiguration+Extensions.swift
//
//  Created by Shinren Pan on 2024/6/2.
//

import UIKit
import WebParser

extension ParserConfiguration {
    static func detail(comic: Comic) -> Self {
        let uri = "https://m.manhuagui.com/comic/" + comic.id
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

    static func images(comic: Comic, episode: Comic.Episode) -> Self {
        let uri = "https://tw.manhuagui.com/comic/\(comic.id)/\(episode.id).html"
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
        let uri = "https://www.manhuagui.com/update/"
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
}
