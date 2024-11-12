//
//  UpdateRouter.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension Update {
    @MainActor
    final class Router {
        weak var vc: VC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let to = Detail.VC(comicId: comicId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
        
        func toRemoteSearch() {
            let to = Search.VC()
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
