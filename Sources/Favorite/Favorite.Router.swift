//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Favorite {
    final class Router {
        weak var vc: Favorite.VC?
    }
}

// MARK: - Route to

extension Favorite.Router {
    func toDetail(comic: Comic.Models.DisplayComic) {
        let to = Detail.VC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.pushViewController(to, animated: true)
    }
}
