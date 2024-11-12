//
//  UpdateVO.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension Update {
    @MainActor
    final class VO {
        let mainView = UIView(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.backgroundColor, value: .white)
        
        let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.refreshControl, value: .init(frame: .zero))
            .setup(\.keyboardDismissMode, value: .onDrag)
        
        let searchItem = UIBarButtonItem()
        
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
    }
}
