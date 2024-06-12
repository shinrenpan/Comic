//
//  SearchListRouter.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

final class SearchListRouter {
    weak var vc: SearchListVC?
}

// MARK: - Public

extension SearchListRouter {
    func toDetail(comic: Comic) {
        let to = DetailVC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
