//
//  UpdateVC+Router.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

extension UpdateVC {
    @MainActor
    final class Router {
        weak var vc: UpdateVC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let to = DetailVC(comicId: comicId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
        
        func toRemoteSearch() {
            let to = SearchVC()
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
