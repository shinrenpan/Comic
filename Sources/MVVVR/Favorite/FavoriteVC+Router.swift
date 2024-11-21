//
//  FavoriteVC+Router.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension FavoriteVC {
    @MainActor
    final class Router {
        weak var vc: FavoriteVC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let to = DetailVC(comicId: comicId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
