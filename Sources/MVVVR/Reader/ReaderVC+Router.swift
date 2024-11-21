//
//  ReaderVC+Router.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit

extension ReaderVC {
    @MainActor final class Router {
        weak var vc: ReaderVC?
        
        // MARK: - Public
        
        func showEpisodePicker(comicId: String, epidoseId: String) {
            let list = EpisodePicker.VC(comicId: comicId, episodeId: epidoseId)
            list.delegate = vc

            let to = UINavigationController(rootViewController: list)
            
            if let sheet = to.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }

            vc?.present(to, animated: true)
        }
    }
}
