//
//  ViewModel.swift
//  Update
//
//  Created by Joe Pan on 2025/3/5.
//

import Foundation
import DataBase
import AnyCodable
import Extensions
import WebParser

@MainActor @Observable final class ViewModel {
    private(set) var state = State.none
    private let parser = Parser(parserConfiguration: .update())
}

// MARK: - Internal

internal extension ViewModel {
    func doAction(_ action: Action) {
        switch action {
        case .loadData:
            actionLoadData()
        case .loadRemote:
            actionLoadRemote()
        case let .localSearch(request):
            actionLocalSearch(request: request)
        case let .changeFavorite(request):
            actionChangeFavorite(request: request)
        }
    }
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData() {
        Task {
            let comics = await DataBase.Storage.shared.getAll(fetchLimit: 1000)
            let response = DataLoadedResponse(comics: comics.compactMap { .init(comic: $0) })
            state = .dataLoaded(response: response)
        }
    }
    
    func actionLoadRemote() {
        Task {
            do {
                let result = try await parser.anyResult()
                let array = AnyCodable(result).anyArray ?? []
                await DataBase.Storage.shared.insertOrUpdateComics(array)
                actionLoadData()
            }
            catch {
                actionLoadData()
            }
        }
    }
    
    func actionLocalSearch(request: LocalSearchRequest) {
        Task {
            let comics = await DataBase.Storage.shared.getAll(keywords: request.keywords)
            let response = LocalSearchedResponse(comics: comics.compactMap { .init(comic: $0) })
            state = .localSearched(response: response)
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
}
