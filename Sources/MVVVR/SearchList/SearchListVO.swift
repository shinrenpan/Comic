//
//  SearchListVO.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

final class SearchListVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.keyboardDismissMode, value: .onDrag)

    let zhHansSwitcher = UISwitch(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.isOn, value: true)

    init() {
        addViews()
    }
}

// MARK: - Public

extension SearchListVO {
    func reloadUI(comics: [Comic], dataSource: SearchListModels.DataSource) {
        var snapshot = SearchListModels.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(comics, toSection: .main)
        dataSource.apply(snapshot)
    }

    func reloadItem(_ item: Comic, dataSource: SearchListModels.DataSource) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([item])
        dataSource.apply(snapshot)
    }
}

// MARK: - Private

private extension SearchListVO {
    // MARK: Add Something

    func addViews() {
        let switchContainer = makeSwitchContainer()

        mainView.addSubview(switchContainer)
        mainView.addSubview(list)

        NSLayoutConstraint.activate([
            switchContainer.topAnchor.constraint(equalTo: mainView.topAnchor),
            switchContainer.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            switchContainer.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            list.topAnchor.constraint(equalTo: switchContainer.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
        ])
    }

    // MARK: - Make Something

    func makeSwitchContainer() -> UIView {
        let label = UILabel(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.font, value: .preferredFont(forTextStyle: .subheadline))
            .setup(\.text, value: "自動繁體轉簡體")

        let result = UIStackView(arrangedSubviews: [label, zhHansSwitcher])
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.axis, value: .horizontal)
            .setup(\.alignment, value: .center)
            .setup(\.distribution, value: .equalSpacing)
            .setup(\.isLayoutMarginsRelativeArrangement, value: true)
            .setup(\.layoutMargins, value: .init(top: 8, left: 8, bottom: 8, right: 8))

        return result
    }
}
