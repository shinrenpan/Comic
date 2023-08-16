//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit
import WebParser

extension Detail {
    final class VM {
        @Published var state = Detail.Models.State.none
        lazy var parser = makeParser()
        let comic: Comic.Models.DisplayComic
        let favoriteWorker = FavoriteWorker()
        let historyWorker = HistoryWorker()
        
        init(comic: Comic.Models.DisplayComic) {
            self.comic = comic
        }
    }
}

// MARK: - Computed Properties

extension Detail.VM {
    var episodes: [Comic.Models.DisplayEpisode] {
        comic.detail?.episodes ?? []
    }
}

// MARK: - Do Action

extension Detail.VM {
    func doAction(_ action: Detail.Models.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case .tapFavorite:
            actionTapFavorite()
        case let .saveHistory(episode):
            actionSaveHistory(episode: episode)
        }
    }
}

// MARK: - Handle Action

private extension Detail.VM {
    func actionLoadData() {
        guard let parser else {
            state = .showError(message: "初始失敗")
            return
        }
        
        state = .showLoading
        
        Task {
            do {
                comic.detail = try await parser.parse(Comic.Models.DisplayDetail.self)
                
                comic.detail?.episodes.forEach {
                    $0.watched = historyWorker.isWatched(comic: comic, episode: $0)
                }
                
                state = .hideLoading
                state = .loadedData
            }
            catch {
                comic.detail = nil
                state = .hideLoading
                state = .showError(message: "Timeout")
            }
        }
    }
    
    func actionTapFavorite() {
        switch comic.isFavorite {
        case true:
            comic.isFavorite = false
            favoriteWorker.removeFavorite(comic: comic)
        case false:
            comic.isFavorite = true
            favoriteWorker.addFavorite(comic: comic)
        }
        
        state = .tapFavorite
    }
    
    func actionSaveHistory(episode: Comic.Models.DisplayEpisode) {
        historyWorker.addWatched(comic: comic, episode: episode)
        episodes.forEach { $0.watched = ($0 == episode) }
    }
}

// MARK: - Response Action

private extension Detail.VM {}

// MARK: - Convert Something

private extension Detail.VM {}

// MARK: - Make Something

private extension Detail.VM {
    func makeParser() -> Parser? {
        guard let javascript = makeJavascript() else {
            return nil
        }
        
        let uri = "https://m.manhuagui.com" + comic.detailPath
        
        let configure = WebParser.Configuration(
            uri: uri,
            retryInterval: 1,
            retryCount: 15,
            userAgent: .iPhone,
            javascript: javascript)
        
        return .init(configuration: configure)
    }
    
    func makeJavascript() -> String? {
        guard let path = Bundle.main.url(forResource: "Detail", withExtension: "js") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
