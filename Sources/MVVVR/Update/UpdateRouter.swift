//
//  UpdateListRouter.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension Update {
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
