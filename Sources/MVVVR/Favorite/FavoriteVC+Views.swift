//
//  FavoriteVC+Views.swift
//
//  Created by Joe Pan on 2024/10/28.
//

import UIKit
import SwiftUI
import Kingfisher

extension FavoriteVC {
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
                    Text(comic.title)
                        .font(.headline)
                    Text(comic.note)
                        .font(.subheadline)
                    Spacer(minLength: 8)
                    Text(makeWatchDate())
                            .font(.footnote)
                    
                    HStack {
                        Text(makeLastUpdate())
                            .font(.footnote)
                        
                        if comic.hasNew {
                            Text("New")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Spacer(minLength: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        // MARK: - Make Something
        
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
