//
//  ReaderRouter.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit

final class ReaderRouter {
    weak var vc: ReaderVC?
}

// MARK: - Public

extension ReaderRouter {
    func showEpisodePicker(comic: Comic) {
        let picker = EpisodeListVC(comic: comic)
        picker.delegate = vc

        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        vc?.present(picker, animated: true)
    }
}
