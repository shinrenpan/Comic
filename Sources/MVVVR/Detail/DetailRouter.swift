//
//  DetailRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Detail {
    final class Router {
        weak var vc: ViewController?
        
        // MARK: - Public
        
        func toReader(comicId: String, episodeId: String) {
            let to = Reader.ViewController(comicId: comicId, episodeId: episodeId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
