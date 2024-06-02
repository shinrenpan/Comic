//
//  Comic.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import SwiftData
import UIKit

@Model
final class Comic: Hashable {
    /// Id
    @Attribute(.unique) let id: String

    /// Title
    var title: String

    /// 更新至...
    var note: String

    /// 最後更新時間
    var lastUpdate: TimeInterval

    /// 是否收藏
    var favorited: Bool

    /// Detail
    @Relationship(deleteRule: .cascade, inverse: \Detail.comic) var detail: Detail?

    /// 集數
    @Relationship(deleteRule: .cascade, inverse: \Episode.comic) var episodes: [Episode]?

    /// 最後觀看集數 Id
    var watchedId: String?

    /// 最後觀看時間
    var watchDate: Date?

    var hasNew: Bool

    init(id: String, title: String, note: String, lastUpdate: TimeInterval, favorited: Bool, detail: Detail? = nil, episodes: [Episode]? = nil, watchedId: String? = nil, watchDate: Date? = nil, hasNew: Bool) {
        self.id = id
        self.title = title
        self.note = note
        self.lastUpdate = lastUpdate
        self.favorited = favorited
        self.detail = detail
        self.episodes = episodes
        self.watchedId = watchedId
        self.watchDate = watchDate
        self.hasNew = hasNew
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func updateHasNew() {
        hasNew = hasVew()
    }

    func hasVew() -> Bool {
        guard let watchDate else {
            return true
        }

        if lastUpdate > watchDate.timeIntervalSince1970 {
            return true
        }

        // 最新集數 id != 看過的 id
        return episodes?.first(where: { $0.index == 0 })?.id != watchedId
    }
}

extension Comic {
    @Model
    final class Detail {
        var comic: Comic?
        /// 封面
        var cover: String
        /// 描述
        var desc: String
        /// 作者
        var author: String

        init(comic: Comic? = nil, cover: String, desc: String, author: String) {
            self.comic = comic
            self.cover = cover
            self.desc = desc
            self.author = author
        }
    }
}

extension Comic {
    @Model
    final class Episode: Hashable {
        var comic: Comic?
        /// Id
        let id: String
        /// Index
        let index: Int
        /// Title
        let title: String

        init(comic: Comic? = nil, id: String, index: Int, title: String) {
            self.comic = comic
            self.id = id
            self.index = index
            self.title = title
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

extension Comic {
    final class ImageData {
        /// Index
        let index: Int
        /// 圖片 URI
        let uri: String

        init(index: Int, uri: String) {
            self.index = index
            self.uri = uri
        }
    }
}
