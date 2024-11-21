//
//  HistoryVC+Router.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

extension HistoryVC {
    @MainActor final class Router {
        weak var vc: HistoryVC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let to = Detail.VC(comicId: comicId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
