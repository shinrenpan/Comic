//
//  DBWorker.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import SwiftData
import UIKit

actor DBWorker {
    static let shared = DBWorker()
    private var container: ModelContainer?
    private var context: ModelContext?

    private init() {
        self.container = try? ModelContainer(for: Comic.self)

        if let container {
            self.context = .init(container)
            context?.autosaveEnabled = true
        }
    }
}

// MARK: - Public

extension DBWorker {
    /// 取得單一漫畫 by Id.
    /// - Parameter id: 漫畫 Id.
    /// - Returns: 返回單一漫畫.
    func getComicById(_ id: String) -> Comic? {
        let descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.id == id
        })

        return try? context?.fetch(descriptor).first
    }

    /// 取得所有漫畫列表.
    func getComicList() -> [Comic] {
        let descriptor = FetchDescriptor<Comic>(sortBy: [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ])

        return (try? context?.fetch(descriptor)) ?? []
    }

    /// 取得依關鍵字搜尋的漫畫列表.
    /// - Parameter keywords: 關鍵字.
    /// - Returns: 返回漫畫列表.
    func getComicListByKeywords(_ keywords: String) -> [Comic] {
        if keywords.isEmpty { return [] }

        let descriptor = FetchDescriptor<Comic>(
            predicate: #Predicate {
                $0.title.contains(keywords)
            },
            sortBy: [
                SortDescriptor(\.lastUpdate, order: .reverse),
            ]
        )

        return (try? context?.fetch(descriptor)) ?? []
    }

    /// 取得觀看過的漫畫列表.
    /// - Returns: 返回漫畫列表.
    func getComicHistoryList() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.watchedId != nil
        })

        descriptor.sortBy = [
            SortDescriptor(\.watchDate, order: .reverse),
        ]

        return (try? context?.fetch(descriptor)) ?? []
    }

    /// 取得加入收藏的漫畫列表.
    /// - Returns: 返回漫畫列表.
    func getComicFavoriteList() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.favorited
        })

        descriptor.sortBy = [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ]

        return (try? context?.fetch(descriptor)) ?? []
    }

    /// 更新漫畫集數.
    /// - Parameters:
    ///   - comic: 要更新的漫畫.
    ///   - episodes: 集數.
    func updateComicEpisodes(_ comic: Comic, episodes: [Comic.Episode]) {
        comic.episodes?.forEach {
            context?.delete($0)
        }

        comic.episodes = episodes
        comic.updateHasNew()
    }

    /// 移除所有觀看過的漫畫.
    func removeAllComicHistory() {
        for comic in getComicList() {
            removeComicHistory(comic)
        }
    }

    /// 移除單一漫畫的觀看紀錄.
    /// - Parameter comic: 要移除的漫畫.
    func removeComicHistory(_ comic: Comic) {
        comic.watchedId = nil
        comic.watchDate = nil
        comic.updateHasNew()
    }

    /// 新增單一漫畫觀看紀錄.
    /// - Parameters:
    ///   - comic: 要新增的漫畫.
    ///   - episode: 觀看的級數.
    func addComicHistory(_ comic: Comic, episode: Comic.Episode) {
        comic.watchedId = episode.id
        comic.watchDate = .now
        comic.updateHasNew()
    }

    /// 新增或更新漫畫
    /// - Parameter anyCodables: 要新增或更新的資料.
    func insertOrUpdateComics(_ anyCodables: [AnyCodable]) {
        for anyCodable in anyCodables {
            guard let id = anyCodable["id"].string, !id.isEmpty else {
                continue
            }

            let title = anyCodable["title"].string ?? "unKnown"
            let note = anyCodable["note"].string ?? "unKnown"
            let lastUpdate = anyCodable["lastUpdate"].double ?? Date().timeIntervalSince1970
            let detailCover = anyCodable["detail"]["cover"].string ?? ""

            if let comic = getComicById(id) {
                comic.title = anyCodable["title"].string ?? "unKnown"
                comic.note = note
                comic.lastUpdate = lastUpdate
                comic.detail?.cover = detailCover
                comic.updateHasNew()
            }
            else {
                let comic = Comic(
                    id: id,
                    title: title,
                    note: note,
                    lastUpdate: lastUpdate,
                    favorited: false,
                    detail: .init(cover: detailCover, desc: "", author: ""),
                    hasNew: true
                )

                context?.insert(comic)
            }
        }
    }
}
