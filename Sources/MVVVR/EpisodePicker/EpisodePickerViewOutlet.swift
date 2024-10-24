//
//  EpisodeListVO.swift
//
//  Created by Shinren Pan on 2024/6/4.
//

import UIKit

extension EpisodePicker {
    final class ViewOutlet {
        let mainView = UIView(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.backgroundColor, value: .white)
        
        let list = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        
        init() {
            addViews()
        }
        
        // MARK: - Public
        
        func scrollListToWatched(indexPath: IndexPath?) {
            guard let indexPath else {
                return
            }
            
            list.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
        
        // MARK: - Add Something

        private func addViews() {
            mainView.addSubview(list)

            NSLayoutConstraint.activate([
                list.topAnchor.constraint(equalTo: mainView.topAnchor),
                list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
                list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
                list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            ])
        }

        // MARK: - Make Something

        private static func makeListLayout() -> UICollectionViewCompositionalLayout {
            let config = UICollectionLayoutListConfiguration(appearance: .plain)

            return UICollectionViewCompositionalLayout.list(using: config)
        }
    }
}
