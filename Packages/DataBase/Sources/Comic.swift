//
//  Comic.swift
//  DataBase
//
//  Created by Joe Pan on 2025/3/5.
//

import Foundation
import SwiftData

@Model public final class Comic: @unchecked Sendable {
    /// Id
    @Attribute(.unique) public private(set) var id: String
    
    /// Title
    public var title: String
    
    public var cover: String
    
    /// 更新至...
    public var note: String
    
    /// 最後更新時間
    public var lastUpdate: TimeInterval
    
    /// 是否收藏
    public var favorited: Bool
    
    /// Detail
    @Relationship(deleteRule: .cascade, inverse: \Detail.comic) public var detail: Detail?
    
    /// 集數
    @Relationship(deleteRule: .cascade, inverse: \Episode.comic) public var episodes: [Episode]?
    
    /// 最後觀看集數 Id
    public var watchedId: String?
    
    /// 最後觀看時間
    public var watchDate: Date?
    
    public var hasNew: Bool
    
    init(id: String, title: String, cover: String, note: String, lastUpdate: TimeInterval, favorited: Bool, detail: Detail? = nil, episodes: [Episode]? = nil, watchedId: String? = nil, watchDate: Date? = nil, hasNew: Bool) {
        self.id = id
        self.title = title
        self.cover = cover
        self.note = note
        self.lastUpdate = lastUpdate
        self.favorited = favorited
        self.detail = detail
        self.episodes = episodes
        self.watchedId = watchedId
        self.watchDate = watchDate
        self.hasNew = hasNew
    }
}

// MARK: - Internal

extension Comic {
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
