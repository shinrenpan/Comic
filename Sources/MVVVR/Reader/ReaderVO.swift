//
//  ReaderVO.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit

final class ReaderVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    let prevItem = UIBarButtonItem(title: "上一話")
        .setup(\.isEnabled, value: false)

    let directionItem = UIBarButtonItem(title: "")
        .setup(\.isEnabled, value: false)
    let nextItem = UIBarButtonItem(title: "下一話")
        .setup(\.isEnabled, value: false)

    let prevLabel = UILabel(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.layer.zPosition, value: -1)
        .setup(\.isHidden, value: true)
        .setup(\.font, value: .preferredFont(forTextStyle: .headline))

    let nextLabel = UILabel(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.layer.zPosition, value: -1)
        .setup(\.isHidden, value: true)
        .setup(\.font, value: .preferredFont(forTextStyle: .headline))

    init() {
        setupSelf()
        addViews()
    }
}

// MARK: - Public

extension ReaderVO {
    func reloadUI(model: ReaderModels.DisplayModel) {
        list.setContentOffset(.zero, animated: false)
        mainView.isHidden = false
        list.reloadData()
        mainView.isUserInteractionEnabled = true
        prevItem.isEnabled = model.hasPrev
        prevItem.title = model.prevEpisode?.title ?? "上一話"
        nextItem.isEnabled = model.hasNext
        nextItem.title = model.nextEpisode?.title ?? "下一話"

        prevLabel.text = model.prevEpisode?.title ?? "上一話"
        prevLabel.isHidden = !model.hasPrev
        nextLabel.text = model.nextEpisode?.title ?? "下一話"
        nextLabel.isHidden = !model.hasNext
    }

    func reloadDisableAll() {
        mainView.isHidden = true
        prevItem.isEnabled = false
        prevLabel.isHidden = true
        directionItem.isEnabled = false
        nextItem.isEnabled = false
        nextLabel.isHidden = true
    }
}

// MARK: - Private

private extension ReaderVO {
    // MARK: Setup Something

    func setupSelf() {
        // CompostiLayout need
        // list.bounces = false
        list.contentInsetAdjustmentBehavior = .never
        // list.insetsLayoutMarginsFromSafeArea = false
        list.registerCell(ReaderCell.self)
    }

    // MARK: - Add Something

    func addViews() {
        list.addSubview(nextLabel)
        list.addSubview(prevLabel)

        mainView.addSubview(list)

        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: mainView.topAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20),

            prevLabel.centerYAnchor.constraint(equalTo: list.centerYAnchor),
            prevLabel.leadingAnchor.constraint(equalTo: list.frameLayoutGuide.leadingAnchor, constant: 4),

            nextLabel.centerYAnchor.constraint(equalTo: list.centerYAnchor),
            nextLabel.trailingAnchor.constraint(equalTo: list.frameLayoutGuide.trailingAnchor, constant: -4),
        ])
    }
}
