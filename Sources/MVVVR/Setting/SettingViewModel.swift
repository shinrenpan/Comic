//
//  SettingVM.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
import Kingfisher
import UIKit

extension Setting {
    @Observable final class ViewModel {
        var state = State.none
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .cleanFavorite:
                actionCleanFavorite()
            case .cleanHistory:
                actionCleanHistory()
            case .cleanCache:
                actionCleanCache()
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comicCount = await DBWorker.shared.getComicList().count
                let favoriteCount = await DBWorker.shared.getComicFavoriteList().count
                let historyCount = await DBWorker.shared.getComicHistoryList().count
                let cacheSize = await getCacheImagesSize()
                let version = Bundle.main.version + "/" + Bundle.main.build

                let items: [Item] = [
                    .init(title: "本地資料", subTitle: "\(comicCount) 筆", settingType: .localData),
                    .init(title: "收藏紀錄", subTitle: "\(favoriteCount) 筆", settingType: .favorite),
                    .init(title: "觀看紀錄", subTitle: "\(historyCount) 筆", settingType: .history),
                    .init(title: "暫存圖片", subTitle: cacheSize, settingType: .cacheSize),
                    .init(title: "版本", subTitle: version, settingType: .version),
                ]

                state = .dataLoaded(response: .init(items: items))
            }
        }

        private func actionCleanFavorite() {
            Task {
                await DBWorker.shared.getComicFavoriteList().forEach { $0.favorited = false }
                actionLoadData()
            }
        }

        private func actionCleanHistory() {
            Task {
                await DBWorker.shared.removeAllComicHistory()
                actionLoadData()
            }
        }

        private func actionCleanCache() {
            ImageCache.default.clearDiskCache { [weak self] in
                guard let self else { return }
                actionLoadData()
            }
        }
        
        // MARK: - Get Something

        private func getCacheImagesSize() async -> String {
            let size: UInt = await (try? ImageCache.default.diskStorageSize) ?? 0

            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file

            return formatter.string(fromByteCount: Int64(size))
        }
    }
}
