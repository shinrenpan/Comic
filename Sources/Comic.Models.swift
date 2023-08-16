//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

enum Comic {
    enum Models {}
}

extension Comic.Models {
    final class DisplayEpisode: Codable, Equatable {
        var id: String {
            path.toMD5() ?? UUID().uuidString
        }
        
        var watched: Bool = false
        var imgs: [String] = []
        let title: String
        let path: String
        
        private enum CodingKeys: String, CodingKey {
            case title
            case path
        }
        
        static func == (lhs: Comic.Models.DisplayEpisode, rhs: Comic.Models.DisplayEpisode) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    final class DisplayDetail: Codable {
        let author: String
        let desc: String
        let episodes: [DisplayEpisode]
    }
    
    final class DisplayComic: Codable, Equatable {
        var id: String {
            detailPath.toMD5() ?? UUID().uuidString
        }
        
        var isFavorite: Bool = false
        let title: String
        let detailPath: String
        let imageURI: String
        let episode: String
        var detail: DisplayDetail?
        
        private enum CodingKeys: String, CodingKey {
            case title
            case detailPath
            case imageURI
            case episode
        }
        
        static func == (lhs: Comic.Models.DisplayComic, rhs: Comic.Models.DisplayComic) -> Bool {
            lhs.id == rhs.id
        }
    }
}
