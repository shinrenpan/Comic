//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit
import WebParser

extension Update {
    final class VM {
        @Published var state = Update.Models.State.none
        var comics: [Comic.Models.DisplayComic] = []
        lazy var parser = makeParser()
        let favoriteWorker = FavoriteWorker()
    }
}

// MARK: - Do Action

extension Update.VM {
    func doAction(_ action: Update.Models.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case let .addFavorite(comic):
            actionFavorite(comic: comic)
        case let .removeFavorite(comic):
            actionRemoveFavorite(comic: comic)
        case .checkFavorite:
            actionCheckoutFavorite()
        }
    }
}

// MARK: - Handle Action

private extension Update.VM {
    func actionLoadData() {
        guard let parser else {
            state = .showError(message: "初始失敗")
            return
        }
        
        state = .showLoading
        
        Task {
            do {
                let data = try await parser.parse()
                self.comics = try convertToComics(data: data)
                
                self.comics.forEach {
                    $0.isFavorite = favoriteWorker.isFavorite(comic: $0)
                }
                
                state = .hideLoading
                state = .loadedData
            }
            catch {
                comics = []
                state = .hideLoading
                state = .showError(message: error.localizedDescription)
            }
        }
    }
    
    func actionFavorite(comic: Comic.Models.DisplayComic) {
        comic.isFavorite = true
        favoriteWorker.addFavorite(comic: comic)
        state = .addFavorite
    }
    
    func actionRemoveFavorite(comic: Comic.Models.DisplayComic) {
        comic.isFavorite = false
        favoriteWorker.removeFavorite(comic: comic)
        state = .removeFavorite
    }
    
    func actionCheckoutFavorite() {
        comics.forEach {
            $0.isFavorite = favoriteWorker.isFavorite(comic: $0)
        }
        
        state = .loadedData
    }
}

// MARK: - Response Action

private extension Update.VM {}

// MARK: - Convert Something

private extension Update.VM {
    func convertToComics(data: Any) throws -> [Comic.Models.DisplayComic] {
        let json = try JSONSerialization.data(withJSONObject: data, options: [])
        return try JSONDecoder().decode([Comic.Models.DisplayComic].self, from: json)
    }
}

// MARK: - Make Something

private extension Update.VM {
    func makeParser() -> Parser? {
        guard let javascript = makeJavascript() else {
            return nil
        }
        
        let uri = "https://tw.manhuagui.com/update"
        
        let configure = WebParser.Configuration(
            uri: uri,
            retryInterval: 1,
            retryCount: 15,
            userAgent: .safari,
            javascript: javascript)
        
        return .init(configuration: configure)
    }
    
    func makeJavascript() -> String? {
        guard let path = Bundle.main.url(forResource: "Update", withExtension: "js") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
