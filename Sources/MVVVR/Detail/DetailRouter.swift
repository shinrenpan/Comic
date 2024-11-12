//
//  DetailRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Detail {
    @MainActor
    final class Router {
        weak var vc: VC?
        
        // MARK: - Public
        
        func toReader(comicId: String, episodeId: String) {
            let to = Reader.VC(comicId: comicId, episodeId: episodeId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
