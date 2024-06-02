//
//  HistoryContentView.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import Kingfisher
import SwiftUI

struct HistoryContentView: View {
    @Bindable var comic: Comic
    let dateFormatter = DateFormatter()
    let converURL: URL?
    let watchDate: String
    let lastUpdate: String

    init(comic: Comic) {
        self.comic = comic

        if let uri = comic.detail?.cover {
            self.converURL = URL(string: "https:\(uri)")
        }
        else {
            self.converURL = nil
        }

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let watchDate = comic.watchDate {
            self.watchDate = "觀看時間: " + dateFormatter.string(from: watchDate)
        }
        else {
            self.watchDate = "觀看時間: unKnown"
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

                Text(watchDate)
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
