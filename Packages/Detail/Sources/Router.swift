//
//  Router.swift
//  Detail
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import Reader

@MainActor final class Router {
    weak var vc: ViewController?
}

extension Router {
    func toReader(comicId: String, episodeId: String) {
        let to = Reader.ViewController(comicId: comicId, episodeId: episodeId)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
