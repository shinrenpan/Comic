//
//  UICollectionView+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: "\(T.self)")
    }

    func reuseCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }

    func registerHeader<T: UICollectionReusableView>(_ type: T.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(T.self)")
    }

    func reuseHeader<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
}
