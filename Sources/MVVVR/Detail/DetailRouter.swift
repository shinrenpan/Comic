//
//  DetailRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class DetailRouter {
    weak var vc: DetailVC?
}

// MARK: - Public

extension DetailRouter {
    func toReader(comic: Comic, episode: Comic.Episode) {
        let to = ReaderVC(comic: comic, episode: episode)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.show(to, sender: nil)
    }
}
