//
//  ReaderModel.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit
import WebParser

extension Reader {
    // MARK: - Action / Request
    
    enum Action {
        case loadData(request: LoadDataRequest)
        case updateFavorite
        case loadPrev
        case loadNext
    }
    
    struct LoadDataRequest {
        let epidoseId: String?
    }
    
    // MARK: - State / Response
    
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
        case checkoutFavorited(response: FavoriteResponse)
        case dataLoadFail(response: ImageLoadFailResponse)
    }
    
    struct DataLoadedResponse {
        let episodeTitle: String?
        let hasPrev: Bool
        let hasNext: Bool
    }
    
    struct FavoriteResponse {
        let isFavorited: Bool
    }
    
    struct ImageLoadFailResponse {
        let error: LoadImageError
    }
    
    // MARK: - Models
    
    enum ReadDirection {
        case horizontal
        case vertical
        
        var toChangeTitle: String {
            switch self {
            case .horizontal:
                "直式閱讀"
            case .vertical:
                "橫向閱讀"
            }
        }
    }
    
    enum LoadImageError: Error {
        case parseFail
        case empty
        case noPrev
        case noNext
    }

    final class ImageData {
        let uri: String
        var image: UIImage?
        
        init(uri: String, image: UIImage? = nil) {
            self.uri = uri
            self.image = image
        }
    }
}
