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
}
