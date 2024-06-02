//
//  FavoriteRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class FavoriteRouter {
    weak var vc: FavoriteVC?
}

// MARK: - Public

extension FavoriteRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
