//
//  CellContentView.swift
//
//  Created by Shinren Pan on 2024/6/13.
//

import Kingfisher
import SwiftUI
import UIKit

struct CellContentView: View {
    @Bindable var comic: Comic
    let dateFormatter = DateFormatter()
    let converURL: URL?
    let lastUpdate: String
    let inFavoriteList: Bool

    init(comic: Comic, inFavoriteList: Bool) {
        self.comic = comic
        self.inFavoriteList = inFavoriteList

        if let uri = comic.detail?.cover {
            self.converURL = URL(string: "https:\(uri)")
        }
        else {
            self.converURL = nil
        }

        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
        self.lastUpdate = "最後更新: " + dateFormatter.string(from: lastUpdate)
    }

    var body: some View {
        HStack(alignment: .top) {
            KFImage(converURL)
                .resizable()
                .frame(width: 70, height: 90)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    if comic.favorited, !inFavoriteList {
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

                HStack {
                    Text(lastUpdate)
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

private extension CellContentView {
    func makeWatchDate() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let watchDate = comic.watchDate {
            return "觀看時間: " + dateFormatter.string(from: watchDate)
        }
        else {
            return "觀看時間: 未觀看"
        }
    }
}
