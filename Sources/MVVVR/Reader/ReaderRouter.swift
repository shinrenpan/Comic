//
//  ReaderRouter.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit

extension Reader {
    final class Router {
        weak var vc: ViewController?
        
        // MARK: - Public
        
        func showEpisodePicker(comic: Comic) {
            let list = EpisodePicker.ViewController(comic: comic)
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
