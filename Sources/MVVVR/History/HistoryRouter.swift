//
//  HistoryListRouter.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

extension History {
    final class Router {
        weak var vc: ViewController?
        
        // MARK: - Public
        
        func toDetail(comic: Comic) {
            let to = Detail.ViewController(comic: comic)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
