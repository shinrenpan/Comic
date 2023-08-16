//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit
import WebParser

extension Reader {
    final class VM {
        @Published var state = Reader.Models.State.none
        lazy var parser = makeParser()
        let comic: Comic.Models.DisplayComic
        
        init(comic: Comic.Models.DisplayComic) {
            self.comic = comic
        }
    }
}

// MARK: - Computed Properties

extension Reader.VM {
    var episode: Comic.Models.DisplayEpisode? {
        comic.detail?.episodes.first(where: { $0.watched })
    }
    
    var imgs: [String] {
        episode?.imgs ?? []
    }
}

// MARK: - Do Action

extension Reader.VM {
    func doAction(_ action: Reader.Models.Action) {
        switch action {
        case .loadData:
            actionLoadData()
        }
    }
}

// MARK: - Handle Action

private extension Reader.VM {
    func actionLoadData() {
        guard let parser else {
            state = .showError(message: "初始失敗")
            return
        }
        
        state = .showLoading
        
        Task {
            do {
                episode?.imgs = try await parser.parse([String].self)
                state = .hideLoading
                state = .loadedData
            }
            catch {
                episode?.imgs = []
                state = .hideLoading
                state = .showError(message: "Timeout")
            }
        }
    }
}

// MARK: - Response Action

private extension Reader.VM {}

// MARK: - Convert Something

private extension Reader.VM {}

// MARK: - Make Something

private extension Reader.VM {
    func makeParser() -> Parser? {
        guard let episode else {
            return nil
        }
        
        guard let javascript = makeJavascript() else {
            return nil
        }
        
        let uri = "https://tw.manhuagui.com" + episode.path
        
        let configure = WebParser.Configuration(
            uri: uri,
            retryInterval: 1,
            retryCount: 15,
            userAgent: .safari,
            javascript: javascript)
        
        return .init(configuration: configure)
    }
    
    func makeJavascript() -> String? {
        guard let path = Bundle.main.url(forResource: "Images", withExtension: "js") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
}
