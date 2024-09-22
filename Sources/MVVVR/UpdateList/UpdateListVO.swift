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
        .setup(\.refreshControl, value: .init(frame: .zero))
        .setup(\.keyboardDismissMode, value: .onDrag)

    let searchItem = UIBarButtonItem()
        .setup(\.title, value: "線上查詢")
        .setup(\.isEnabled, value: false)

    init() {
        addViews()
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
