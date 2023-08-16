//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension History {
    final class Router {
        weak var vc: History.VC?
    }
}

// MARK: - Route to

extension History.Router {
    func toDetail(comic: Comic.Models.DisplayComic) {
        let to = Detail.VC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.pushViewController(to, animated: true)
    }
}
