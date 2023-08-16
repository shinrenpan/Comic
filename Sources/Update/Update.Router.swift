//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Update {
    final class Router {
        weak var vc: Update.VC?
    }
}

// MARK: - Route to

extension Update.Router {
    func toDetail(comic: Comic.Models.DisplayComic) {
        let to = Detail.VC(comic: comic)
        to.hidesBottomBarWhenPushed = true
        vc?.navigationController?.pushViewController(to, animated: true)
    }
}
