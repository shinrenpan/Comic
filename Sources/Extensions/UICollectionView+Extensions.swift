//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: T.id)
    }
    
    func reuseCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.id, for: indexPath) as! T
    }
}
