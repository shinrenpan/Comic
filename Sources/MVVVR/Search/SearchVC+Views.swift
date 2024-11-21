//
//  SearchVC+Views.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import UIKit
import SwiftUI
import Kingfisher

extension SearchVC {
    struct Cell: View {
        private let comic: DisplayComic
        private let dateFormatter: DateFormatter = .init()
        
        init(comic: DisplayComic) {
            self.comic = comic
        }
        
        var body: some View {
            HStack(alignment: .top) {
                KFImage(URL(string: "https:" + comic.coverURI))
                    .resizable()
                    .frame(width: 70, height: 90)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        if comic.favorited {
                            Image(systemName: "star.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Text(comic.title)
                            .font(.headline)
                    }
                    
                    Text(comic.note)
                        .font(.subheadline)
                    Spacer(minLength: 8)
                    Text(makeWatchDate())
                            .font(.footnote)
                    Text(makeLastUpdate())
                        .font(.footnote)
                    Spacer(minLength: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        private func makeWatchDate() -> String {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let watchDate = comic.watchDate {
                return "觀看時間: " + dateFormatter.string(from: watchDate)
            }
            else {
                return "觀看時間: 未觀看"
            }
        }
        
        private func makeLastUpdate() -> String {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
            return "最後更新: " + dateFormatter.string(from: lastUpdate)
        }
    }
}
