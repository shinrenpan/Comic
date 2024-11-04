//
//  ComicWorker.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import SwiftData
import UIKit

actor ComicWorker: ModelActor {
    static let shared = ComicWorker()
    nonisolated let modelContainer: ModelContainer
    nonisolated let modelExecutor: any ModelExecutor
    
    private init() {
        let modelContainer = try! ModelContainer(for: Database.Comic.self, Database.Detail.self, Database.Episode.self)
        let modelContext = ModelContext(modelContainer)
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelExecutor.modelContext.autosaveEnabled = true
    }

    // MARK: - Create
    
    func insertOrUpdateComics(_ anyCodables: [AnyCodable]) {
        let descriptor = FetchDescriptor<Database.Comic>()
        let all = (try? modelContext.fetch(descriptor)) ?? []
        
        for anyCodable in anyCodables {
            guard let id = anyCodable["id"].string, !id.isEmpty else {
                continue
            }

            let title = anyCodable["title"].string ?? "unKnown"
            let cover = anyCodable["cover"].string ?? ""
            let note = anyCodable["note"].string ?? "unKnown"
            let lastUpdate = anyCodable["lastUpdate"].double ?? Date().timeIntervalSince1970

            if let comic = all.first(where: {$0.id == id }) {
                comic.title = anyCodable["title"].string ?? "unKnown"
                comic.note = note
                comic.lastUpdate = lastUpdate
                comic.cover = cover
                comic.updateHasNew()
            }
            else {
                let comic = Database.Comic(
                    id: id,
                    title: title,
                    cover: cover,
                    note: note,
                    lastUpdate: lastUpdate,
                    favorited: false,
                    detail: .init(desc: "", author: ""),
                    hasNew: true
                )

                modelContext.insert(comic)
            }
        }
    }
    
    // MARK: - Read
    
    func getComic(id: String) -> Database.Comic? {
        let descriptor = FetchDescriptor<Database.Comic>(predicate: #Predicate { comic in
            comic.id == id
        })

        return try? modelContext.fetch(descriptor).first
    }
    
    func getAll(fetchLimit: Int? = nil) -> [Database.Comic] {
        var descriptor = FetchDescriptor<Database.Comic>(sortBy: [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ])

        if let fetchLimit {
            descriptor.fetchLimit = fetchLimit
        }
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // https://www.hackingwithswift.com/quick-start/swiftdata/how-to-optimize-the-performance-of-your-swiftdata-apps
    func getAllCount() -> Int {
        let descriptor = FetchDescriptor<Database.Comic>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
    
    func getAll(keywords: String) -> [Database.Comic] {
        if keywords.isEmpty { return getAll() }

        let descriptor = FetchDescriptor<Database.Comic>(
            predicate: #Predicate {
                $0.title.contains(keywords)
            },
            sortBy: [
                SortDescriptor(\.lastUpdate, order: .reverse),
            ]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getHistories() -> [Database.Comic] {
        var descriptor = FetchDescriptor<Database.Comic>(predicate: #Predicate { comic in
            comic.watchedId != nil
        })

        descriptor.sortBy = [
            SortDescriptor(\.watchDate, order: .reverse),
        ]

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getHistoryCount() -> Int {
        let descriptor = FetchDescriptor<Database.Comic>(predicate: #Predicate { comic in
            comic.watchedId != nil
        })
        
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
    
    func getFavorites() -> [Database.Comic] {
        var descriptor = FetchDescriptor<Database.Comic>(predicate: #Predicate { comic in
            comic.favorited
        })

        descriptor.sortBy = [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ]

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getFavoriteCount() -> Int {
        let descriptor = FetchDescriptor<Database.Comic>(predicate: #Predicate { comic in
            comic.favorited
        })
        
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
    
    func getEpisodes(comicId: String) -> [Database.Episode] {
        guard let comic = getComic(id: comicId) else {
            return []
        }
        
        // comic.episodes 無排序, 需要先排序
        return comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []
    }
    
    // MARK: - Update
    
    @discardableResult
    func updateFavorite(id: String, favorited: Bool) -> Database.Comic? {
        guard let comic = getComic(id: id) else { return nil }
        comic.favorited = favorited
        return comic
    }
    
    func updateHistory(comicId: String, episodeId: String) {
        guard let comic = getComic(id: comicId) else { return }
        comic.watchedId = episodeId
        comic.watchDate = .now
        comic.updateHasNew()
    }
    
    func updateEpisodes(id: String, episodes: [Database.Episode]) {
        guard let comic = getComic(id: id) else { return }
        
        comic.episodes?.forEach {
            modelContext.delete($0)
        }

        comic.episodes = episodes
        comic.updateHasNew()
    }

    // MARK: - Delete
    
    func removeAllHistory() {
        for comic in getAll() {
            removeHistory(id: comic.id)
        }
    }
    
    func removeAllFavorite() {
        for comic in getAll() {
            comic.favorited = false
        }
    }
    
    func removeHistory(id: String) {
        guard let comic = getComic(id: id) else { return }
        comic.watchedId = nil
        comic.watchDate = nil
        comic.updateHasNew()
    }
}
