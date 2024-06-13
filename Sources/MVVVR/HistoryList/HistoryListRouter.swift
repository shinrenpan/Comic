//
//  HistoryListRouter.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

final class HistoryListRouter {
    weak var vc: HistoryListVC?
}

// MARK: - Public

extension HistoryListRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
