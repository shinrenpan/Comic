//
//  ReaderModel.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit
import WebParser

enum ReaderModel {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    typealias CellRegistration = UICollectionView.CellRegistration<ReaderCell, String>
}

// MARK: - Action

extension ReaderModel {
    enum Action {
        case loadData(request: LoadDataRequest)
        case loadPrev
        case loadNext
    }
    
    struct LoadDataRequest {
        let epidose: Comic.Episode?
    }
}

// MARK: - State

extension ReaderModel {
    enum State {
        case none
        case dataLoaded(response: DataLoadedResponse)
        case dataLoadFail(response: ImageLoadFailResponse)
    }
    
    struct DataLoadedResponse {
        let episode: Comic.Episode
        let hasPrev: Bool
        let hasNext: Bool
    }
    
    struct ImageLoadFailResponse {
        let error: LoadImageError
    }
}

// MARK: - Models

extension ReaderModel {
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
