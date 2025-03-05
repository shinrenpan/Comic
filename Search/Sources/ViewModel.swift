//
//  ViewModel.swift
//  Search
//
//  Created by Joe Pan on 2025/3/5.
//

import Observation
import DataBase
import AnyCodable
import WebParser

@MainActor @Observable final class ViewModel {
    private(set) var state = State.none
    private(set) var hasNextPage: Bool = false
    private var page: Int = 1
}

// MARK: - Internal

extension ViewModel {
    func doAction(_ action: Action) {
        switch action {
        case let .loadData(request):
            actionLoadData(request: request)
        case let .loadNextPage(request):
            actionLoadNextPage(request: request)
        case let .changeFavorite(request):
            actionChangeFavorite(request: request)
        }
    }
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData(request: LoadDataRequest) {
        page = 1
        
        Task {
            do {
                let parser = makeParser(keywords: request.keywords)
                let result = try await parser.anyResult()
                let array = AnyCodable(result).anyArray ?? []
                let comics = await DataBase.Storage.shared.insertOrUpdateComics(array)
                hasNextPage = comics.count >= 10
                let displayComics: [Comic] = comics.compactMap { .init(comic: $0) }
                let response = DataLoadedResponse(comics: displayComics)
                state = .dataLoaded(response: response)
            }
            catch {
                state = .dataLoaded(response: .init(comics: []))
            }
        }
    }
    
    func actionLoadNextPage(request: LoadNextPageRequest) {
        if !hasNextPage { return }
        
        page += 1
        
        Task {
            do {
                let parser = makeParser(keywords: request.keywords)
                let result = try await parser.anyResult()
                let array = AnyCodable(result).anyArray ?? []
                let comics = await DataBase.Storage.shared.insertOrUpdateComics(array)
                hasNextPage = comics.count >= 10
                let displayComics: [Comic] = comics.compactMap { .init(comic: $0) }
                let response = NextPageLoadedResponse(comics: displayComics)
                state = .nextPageLoaded(response: response)
            }
            catch {
                if page > 1 { page -= 1 }
                state = .nextPageLoaded(response: .init(comics: []))
            }
        }
    }
    
    func actionChangeFavorite(request: ChangeFavoriteRequest) {
        Task {
            let comic = request.comic
            
            if let result = await DataBase.Storage.shared.updateFavorite(id: comic.id, favorited: !comic.favorited) {
                let response = FavoriteChangedResponse(comic: .init(comic: result))
                state = .favoriteChanged(response: response)
            }
        }
    }
    
    // MARK: - Make Something
    
    func makeParser(keywords: String) -> Parser {
        .init(parserConfiguration: .search(keywords: keywords, page: page))
    }
}
