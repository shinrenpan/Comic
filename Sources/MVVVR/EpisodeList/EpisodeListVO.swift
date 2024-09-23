//
//  EpisodeListVO.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

final class EpisodeListVO {
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

extension EpisodeListVO {
    func scrollListToWatched(indexPath: IndexPath?) {
        guard let indexPath else {
            return
        }
        
        list.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

// MARK: - Private

private extension EpisodeListVO {
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

    // MARK: - Make Something

    static func makeListLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)

        return UICollectionViewCompositionalLayout.list(using: config)
    }
}
