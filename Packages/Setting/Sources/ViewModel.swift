//
//  ViewModel.swift
//  Setting
//
//  Created by Joe Pan on 2025/3/5.
//

import DataBase
import Extensions
import Foundation
@preconcurrency import Kingfisher

@MainActor @Observable final class ViewModel {
    private(set) var state = State.none
}

// MARK: - Internal

extension ViewModel {
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
}

// MARK: - Private

private extension ViewModel {
    func actionLoadData() {
        Task {
            let comicCount = await DataBase.Storage.shared.getAllCount()
            let favoriteCount = await DataBase.Storage.shared.getFavoriteCount()
            let historyCount = await DataBase.Storage.shared.getHistoryCount()
            let cacheSize = await getCacheImagesSize()
            let version = Bundle.main.version + "/" + Bundle.main.build

            let settigs: [SettingItem] = [
                .init(title: "本地資料", subTitle: "\(comicCount) 筆", settingType: .localData),
                .init(title: "收藏紀錄", subTitle: "\(favoriteCount) 筆", settingType: .favorite),
                .init(title: "觀看紀錄", subTitle: "\(historyCount) 筆", settingType: .history),
                .init(title: "暫存圖片", subTitle: cacheSize, settingType: .cacheSize),
                .init(title: "版本", subTitle: version, settingType: .version),
            ]

            state = .dataLoaded(response: .init(settings: settigs))
        }
    }

    func actionCleanFavorite() {
        Task {
            await DataBase.Storage.shared.removeAllFavorite()
            actionLoadData()
        }
    }

    func actionCleanHistory() {
        Task {
            await DataBase.Storage.shared.removeAllHistory()
            actionLoadData()
        }
    }

    func actionCleanCache() {
        Task {
            await ImageCache.default.asyncCleanDiskCache()
            actionLoadData()
        }
    }
    
    func getCacheImagesSize() async -> String {
        let size: UInt = await (try? ImageCache.default.diskStorageSize) ?? 0

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file

        return formatter.string(fromByteCount: Int64(size))
    }
}
