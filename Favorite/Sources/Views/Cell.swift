//
//  Cell.swift
//  Favorite
//
//  Created by Joe Pan on 2025/3/5.
//

import SwiftUI
import Kingfisher

struct Cell: View {
    private let comic: Comic
    private let dateFormatter: DateFormatter = .init()
    
    init(comic: Comic) {
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
}

// MARK: - Private

private extension Cell {
    func makeWatchDate() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let watchDate = comic.watchDate {
            return "觀看時間: " + dateFormatter.string(from: watchDate)
        }
        else {
            return "觀看時間: 未觀看"
        }
    }
    
    func makeLastUpdate() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
        return "最後更新: " + dateFormatter.string(from: lastUpdate)
    }
}
