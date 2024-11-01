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
        let modelContainer = try! ModelContainer(for: Comic.self, Comic.Detail.self, Comic.Episode.self)
        let modelContext = ModelContext(modelContainer)
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelExecutor.modelContext.autosaveEnabled = true
    }

    // MARK: - Create
    
    func insertOrUpdateComics(_ anyCodables: [AnyCodable]) {
        let all = getAll()
        
        for anyCodable in anyCodables {
            guard let id = anyCodable["id"].string, !id.isEmpty else {
                continue
            }

            let title = anyCodable["title"].string ?? "unKnown"
            let note = anyCodable["note"].string ?? "unKnown"
            let lastUpdate = anyCodable["lastUpdate"].double ?? Date().timeIntervalSince1970
            let detailCover = anyCodable["detail"]["cover"].string ?? ""

            if let comic = all.first(where: {$0.id == id }) {
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

                modelContext.insert(comic)
            }
        }
    }
    
    // MARK: - Read
    
    func getComic(id: String) -> Comic? {
        let descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.id == id
        })

        return try? modelContext.fetch(descriptor).first
    }
    
    func getAll() -> [Comic] {
        let descriptor = FetchDescriptor<Comic>(sortBy: [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ])

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getAll(keywords: String) -> [Comic] {
        if keywords.isEmpty { return getAll() }

        let descriptor = FetchDescriptor<Comic>(
            predicate: #Predicate {
                $0.title.contains(keywords)
            },
            sortBy: [
                SortDescriptor(\.lastUpdate, order: .reverse),
            ]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getHistories() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.watchedId != nil
        })

        descriptor.sortBy = [
            SortDescriptor(\.watchDate, order: .reverse),
        ]

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func getFavorites() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.favorited
        })

        descriptor.sortBy = [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ]

        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getEpisodes(comicId: String) -> [Comic.Episode] {
        guard let comic = getComic(id: comicId) else {
            return []
        }
        
        // comic.episodes 無排序, 需要先排序
        return comic.episodes?.sorted(by: { $0.index < $1.index }) ?? []
    }
    
    // MARK: - Update
    
    func updateFavorite(id: String, favorited: Bool) -> Comic? {
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
    
    func updateEpisodes(id: String, episodes: [Comic.Episode]) {
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
