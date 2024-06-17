//
//  SettingVO.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

final class SettingVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    init() {
        addViews()
    }
}

// MARK: - Public

extension SettingVO {
    func reloadUI(items: [SettingModels.Item], dataSource: SettingModels.DataSource) {
        var snapshot = SettingModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        snapshot.reloadSections([.main])

        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension SettingVO {
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

    // MARK: - Make Something

    static func makeListLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)

        return UICollectionViewCompositionalLayout.list(using: config)
    }
}
