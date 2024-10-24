//
//  SettingVO.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

extension Setting {
    final class ViewOutlet {
        let mainView = UIView(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.backgroundColor, value: .white)
        
        let list = UICollectionView(frame: .zero, collectionViewLayout: makeListLayout())
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        
        init() {
            addViews()
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
