//
//  HistoryVO.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

final class HistoryVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    init() {
        addViews()
    }
}

// MARK: - Public

extension HistoryVO {
    func reloadUI(comics: [Comic], dataSource: HistoryModels.DataSource) {
        var snapshot = HistoryModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot)
    }

    func reloadItem(_ item: Comic, dataSource: HistoryModels.DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }

    func deleteItem(_ item: Comic, dataSource: HistoryModels.DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension HistoryVO {
    // MARK: Add Something

    func addViews() {
        mainView.addSubview(list)

        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: mainView.topAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
        ])
    }
}
