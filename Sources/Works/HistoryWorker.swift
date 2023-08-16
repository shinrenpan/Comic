//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

final class HistoryWorker {
    let folderName = "com.shinrenpan.Comic.history"
    let historyFileName = "history.json"
}

// MARK: - Computed Properties

extension HistoryWorker {
    var comics: [Comic.Models.DisplayComic] {
        let result = getHistoryList()
        return result.compactMap { $0.comic }
    }
}

// MARK: - Public

extension HistoryWorker {
    func isWatched(comic: Comic.Models.DisplayComic, episode: Comic.Models.DisplayEpisode) -> Bool {
        let model = History(comic: comic, episodeId: episode.id)
        let list = getHistoryList()
        return list.contains(model)
    }
    
    func addWatched(comic: Comic.Models.DisplayComic, episode: Comic.Models.DisplayEpisode) {
        let model = History(comic: comic, episodeId: episode.id)
        var list = getHistoryList()
        
        if list.contains(model) {
            return
        }
        
        list.removeAll(where: { $0.comic == model.comic })
        list.insert(model, at: 0)
        saveHistory(histories: list)
    }
    
    func removeWatched(comic: Comic.Models.DisplayComic) {
        var list = getHistoryList()
        list.removeAll(where: { $0.comic == comic })
        saveHistory(histories: list)
    }
    
    func removeAll() {
        saveHistory(histories: [])
    }
}

// MARK: - Model

private extension HistoryWorker {
    struct History: Codable, Equatable {
        let comic: Comic.Models.DisplayComic
        let episodeId: String
    }
}

// MARK: - Get Something

private extension HistoryWorker {
    func getHistoryList() -> [History] {
        guard let path = getHistoryPath() else {
            return []
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([History].self, from: data)
        }
        catch {
            return []
        }
    }
    
    func getHistoryPath() -> URL? {
        let fileManager = FileManager.default
        
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folder = url.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            
            return folder.appendingPathComponent(historyFileName)
        }
        catch {
            return nil
        }
    }
}

// MARK: - Save Something

private extension HistoryWorker {
    func saveHistory(histories: [History]) {
        guard let path = getHistoryPath() else { return }
        guard let data = try? JSONEncoder().encode(histories) else { return }
        
        try? data.write(to: path, options: .atomic)
    }
}
