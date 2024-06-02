//
//  UITableView+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(type, forCellReuseIdentifier: "\(T.self)")
    }

    func reuseCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as! T
    }
}
