//
//  HistoryRouter.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

final class HistoryRouter {
    weak var vc: HistoryVC?
}

// MARK: - Public

extension HistoryRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
