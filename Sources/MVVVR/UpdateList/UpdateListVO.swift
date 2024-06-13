//
//  UpdateListVO.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

final class UpdateListVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.keyboardDismissMode, value: .onDrag)

    init() {
        list.refreshControl = .init(frame: .zero)
        addViews()
    }
}

// MARK: - Public

extension UpdateListVO {
    func reloadUI(comics: [Comic], dataSource: UpdateListModels.DataSource) {
        list.refreshControl?.endRefreshing()

        var snapshot = UpdateListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot)
    }

    func reloadItem(_ item: Comic, dataSource: UpdateListModels.DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension UpdateListVO {
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
