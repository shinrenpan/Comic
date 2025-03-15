//
//  Router.swift
//  Search
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import Detail

@MainActor final class Router {
    weak var vc: ViewController?
}

// MARK: - Internal

extension Router {
    func toDetail(comicId: String) {
        let to = Detail.ViewController(comicId: comicId)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
