//
//  SearchViewModel.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import Observation
import UIKit
import WebParser
import AnyCodable

extension Search {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var state = State.none
        private(set) var hasNextPage: Bool = false
        private var page: Int = 1
        
        // MARK: - Public

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
        
        // MARK: - Handle Action
        
        private func actionLoadData(request: LoadDataRequest) {
            page = 1
            
            Task {
                do {
                    let parser = makeParser(keywords: request.keywords)
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? []
                    let comics = await ComicWorker.shared.insertOrUpdateComics(array)
                    hasNextPage = comics.count >= 10
                    let displayComics: [DisplayComic] = comics.compactMap { .init(comic: $0) }
                    let response = DataLoadedResponse(comics: displayComics)
                    state = .dataLoaded(response: response)
                }
                catch {
                    state = .dataLoaded(response: .init(comics: []))
                }
            }
        }
        
        private func actionLoadNextPage(request: LoadNextPageRequest) {
            if !hasNextPage { return }
            
            page += 1
            
            Task {
                do {
                    let parser = makeParser(keywords: request.keywords)
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? []
                    let comics = await ComicWorker.shared.insertOrUpdateComics(array)
                    hasNextPage = comics.count >= 10
                    let displayComics: [DisplayComic] = comics.compactMap { .init(comic: $0) }
                    let response = NextPageLoadedResponse(comics: displayComics)
                    state = .nextPageLoaded(response: response)
                }
                catch {
                    if page > 1 { page -= 1 }
                    state = .nextPageLoaded(response: .init(comics: []))
                }
            }
        }
        
        private func actionChangeFavorite(request: ChangeFavoriteRequest) {
            Task {
                let comic = request.comic
                
                if let result = await ComicWorker.shared.updateFavorite(id: comic.id, favorited: !comic.favorited) {
                    let response = FavoriteChangedResponse(comic: .init(comic: result))
                    state = .favoriteChanged(response: response)
                }
            }
        }
        
        // MARK: - Make Something
        
        private func makeParser(keywords: String) -> Parser {
            .init(parserConfiguration: .search(keywords: keywords, page: page))
        }
    }
}
