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
    func getById(_ id: String) -> Comic? {
        let descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.id == id
        })

        return try? context?.fetch(descriptor).first
    }

    func getAll() -> [Comic] {
        let descriptor = FetchDescriptor<Comic>(sortBy: [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ])

        return (try? context?.fetch(descriptor)) ?? []
    }

    func getHistoryList() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.watchedId != nil
        })

        descriptor.sortBy = [
            SortDescriptor(\.watchDate, order: .reverse),
        ]

        return (try? context?.fetch(descriptor)) ?? []
    }

    func getFavoriteList() -> [Comic] {
        var descriptor = FetchDescriptor<Comic>(predicate: #Predicate { comic in
            comic.favorited
        })

        descriptor.sortBy = [
            SortDescriptor(\.lastUpdate, order: .reverse),
        ]

        return (try? context?.fetch(descriptor)) ?? []
    }

    func updateEpisodes(comic: Comic, episodes: [Comic.Episode]) {
        comic.episodes?.forEach {
            context?.delete($0)
        }

        comic.episodes = episodes
        comic.updateHasNew()
    }

    func removeAllWatched() {
        for comic in getAll() {
            removeComicWatched(comic)
        }
    }

    func removeComicWatched(_ comic: Comic) {
        comic.watchedId = nil
        comic.watchDate = nil
        comic.updateHasNew()
    }

    func addComicWatched(_ comic: Comic, episode: Comic.Episode) {
        comic.watchedId = episode.id
        comic.watchDate = .now
        comic.updateHasNew()
    }

    func insertOrUpdate(_ anyCodables: [AnyCodable]) {
        for anyCodable in anyCodables {
            guard let id = anyCodable["id"].string, !id.isEmpty else {
                continue
            }

            let title = anyCodable["title"].string ?? "unKnown"
            let note = anyCodable["note"].string ?? "unKnown"
            let lastUpdate = anyCodable["lastUpdate"].double ?? Date().timeIntervalSince1970
            let detailCover = anyCodable["detail"]["cover"].string ?? ""

            if let comic = getById(id) {
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
