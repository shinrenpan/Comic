//
//  FavoriteListRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class FavoriteListRouter {
    weak var vc: FavoriteListVC?
}

// MARK: - Public

extension FavoriteListRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
