//
//  SettingVM.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
import Kingfisher
import UIKit

@Observable final class SettingVM {
    var state = SettingModel.State.none
}

// MARK: - Public

extension SettingVM {
    func doAction(_ action: SettingModel.Action) {
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

private extension SettingVM {
    // MARK: Do Action

    func actionLoadData() {
        Task {
            let comicCount = await DBWorker.shared.getComicList().count
            let favoriteCount = await DBWorker.shared.getComicFavoriteList().count
            let historyCount = await DBWorker.shared.getComicHistoryList().count
            let cacheSize = await getCacheImagesSize()
            let version = Bundle.main.version + "/" + Bundle.main.build

            let items: [SettingModel.Item] = [
                .init(title: "本地資料", subTitle: "\(comicCount) 筆", settingType: .localData),
                .init(title: "收藏紀錄", subTitle: "\(favoriteCount) 筆", settingType: .favorite),
                .init(title: "觀看紀錄", subTitle: "\(historyCount) 筆", settingType: .history),
                .init(title: "暫存圖片", subTitle: cacheSize, settingType: .cacheSize),
                .init(title: "版本", subTitle: version, settingType: .version),
            ]

            state = .dataLoaded(response: .init(items: items))
        }
    }

    func actionCleanFavorite() {
        Task {
            await DBWorker.shared.getComicFavoriteList().forEach { $0.favorited = false }
            actionLoadData()
        }
    }

    func actionCleanHistory() {
        Task {
            await DBWorker.shared.removeAllComicHistory()
            actionLoadData()
        }
    }

    func actionCleanCache() {
        ImageCache.default.clearDiskCache { [weak self] in
            guard let self else { return }
            actionLoadData()
        }
    }

    // MARK: - Get Something

    func getCacheImagesSize() async -> String {
        let size: UInt = await (try? ImageCache.default.diskStorageSize) ?? 0

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file

        return formatter.string(fromByteCount: Int64(size))
    }
}
