//
//  FavoriteVO.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class FavoriteVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    init() {
        addViews()
    }
}

// MARK: - Public

extension FavoriteVO {
    func reloadUI(comics: [Comic], dataSource: FavoriteModels.DataSource) {
        var snapshot = FavoriteModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension FavoriteVO {
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
