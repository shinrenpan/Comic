//
//  Router.swift
//  Reader
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import EpisodePicker

@MainActor final class Router {
    weak var vc: ViewController?
}

// MARK: - Internal

extension Router {
    func showEpisodePicker(comicId: String, epidoseId: String) {
        let list = EpisodePicker.ViewController(comicId: comicId, episodeId: epidoseId)
        list.delegate = vc

        let to = UINavigationController(rootViewController: list)
        
        if let sheet = to.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        vc?.present(to, animated: true)
    }
}
