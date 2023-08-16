//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

final class FavoriteWorker {
    let folderName = "com.shinrenpan.Comic.favorite"
    let favoriteIdsFileName = "favoriteIds.json"
    let favoriteComicsFileName = "favoriteComics.json"
}

// MARK: - Computed Properties

extension FavoriteWorker {
    var comics: [Comic.Models.DisplayComic] {
        let result = getFavoritComics()
        result.forEach { $0.isFavorite = true }
        return result
    }
}

// MARK: - Public

extension FavoriteWorker {
    func isFavorite(comic: Comic.Models.DisplayComic) -> Bool {
        let favoriteIds = getFavoritIds()
        if favoriteIds.isEmpty { return false }
        return favoriteIds.contains(comic.id)
    }
    
    func addFavorite(comic: Comic.Models.DisplayComic) {
        var ids = getFavoritIds()
        var comics = getFavoritComics()
        
        if ids.contains(comic.id) {
            return
        }
        
        ids.insert(comic.id, at: 0)
        comics.insert(comic, at: 0)
        saveFavoriteIds(ids: ids)
        saveFavoriteComics(comics: comics)
    }
    
    func removeFavorite(comic: Comic.Models.DisplayComic) {
        var ids = getFavoritIds()
        var comics = getFavoritComics()
        
        if !ids.contains(comic.id) {
            return
        }
        
        ids.removeAll(where: { $0 == comic.id })
        comics.removeAll(where: { $0.id == comic.id })
        saveFavoriteIds(ids: ids)
        saveFavoriteComics(comics: comics)
    }
    
    func removeAll() {
        saveFavoriteIds(ids: [])
        saveFavoriteComics(comics: [])
    }
}

// MARK: - Get Something

private extension FavoriteWorker {
    func getFavoritIds() -> [String] {
        guard let path = getFavoritIdsPath() else {
            return []
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([String].self, from: data)
        }
        catch {
            return []
        }
    }
    
    func getFavoritComics() -> [Comic.Models.DisplayComic] {
        guard let path = getFavoritComicsPath() else {
            return []
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Comic.Models.DisplayComic].self, from: data)
        }
        catch {
            return []
        }
    }
    
    func getFavoritIdsPath() -> URL? {
        let fileManager = FileManager.default
        
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folder = url.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            
            return folder.appendingPathComponent(favoriteIdsFileName)
        }
        catch {
            return nil
        }
    }
    
    func getFavoritComicsPath() -> URL? {
        let fileManager = FileManager.default
        
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let folder = url.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            
            return folder.appendingPathComponent(favoriteComicsFileName)
        }
        catch {
            return nil
        }
    }
}

// MARK: - Save Something

private extension FavoriteWorker {
    func saveFavoriteIds(ids: [String]) {
        guard let path = getFavoritIdsPath() else { return }
        guard let data = try? JSONEncoder().encode(ids) else { return }
        
        try? data.write(to: path, options: .atomic)
    }
    
    func saveFavoriteComics(comics: [Comic.Models.DisplayComic]) {
        guard let path = getFavoritComicsPath() else { return }
        guard let data = try? JSONEncoder().encode(comics) else { return }
        
        try? data.write(to: path, options: .atomic)
    }
}
