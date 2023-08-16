//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(type, forCellReuseIdentifier: T.id)
    }
    
    func reuseCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.id, for: indexPath) as! T
    }
}
