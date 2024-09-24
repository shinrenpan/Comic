//
//  DetailVO.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class DetailVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let header = DetailHeader()
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.refreshControl, value: .init(frame: .zero))

    let favoriteItem = UIBarButtonItem()
        .setup(\.image, value: .init(systemName: "star"))

    init() {
        addViews()
    }
}

// MARK: - Public

extension DetailVO {
    func reloadHeader(comic: Comic) {
        header.reloadUI(comic: comic)
    }
    
    func reloadFavoriteUI(comic: Comic) {
        let imgNamed = comic.favorited ? "star.fill" : "star"
        let image = UIImage(systemName: imgNamed)
        favoriteItem.image = image
    }
    
    func scrollListToWatched(indexPath: IndexPath?) {
        guard let indexPath else {
            return
        }
        
        list.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

// MARK: - Private

private extension DetailVO {
    // MARK: Add Something

    func addViews() {
        mainView.addSubview(header)
        mainView.addSubview(list)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: mainView.topAnchor),
            header.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            list.topAnchor.constraint(equalTo: header.bottomAnchor),
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
