//
//  UpdateVO.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

final class UpdateVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    init() {
        list.refreshControl = .init(frame: .zero)
        addViews()
    }
}

// MARK: - Public

extension UpdateVO {
    func reloadUI(comics: [Comic], dataSource: UpdateModels.DataSource) {
        list.refreshControl?.endRefreshing()

        var snapshot = UpdateModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot)
    }

    func reloadItem(_ item: Comic, dataSource: UpdateModels.DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension UpdateVO {
    // MARK: - Add Something

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
