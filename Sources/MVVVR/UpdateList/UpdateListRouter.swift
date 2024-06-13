//
//  UpdateListRouter.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

final class UpdateListRouter {
    weak var vc: UpdateListVC?
}

// MARK: - Public

extension UpdateListRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
