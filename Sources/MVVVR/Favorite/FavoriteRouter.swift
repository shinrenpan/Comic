//
//  FavoriteListRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Favorite {
    final class Router {
        weak var vc: ViewController?
        
        // MARK: - Public
        
        func toDetail(comic: Comic) {
            let to = DetailVC(comic: comic)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
