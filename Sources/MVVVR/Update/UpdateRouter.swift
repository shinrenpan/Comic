//
//  UpdateRouter.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

final class UpdateRouter {
    weak var vc: UpdateVC?
}

// MARK: - Public

extension UpdateRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
