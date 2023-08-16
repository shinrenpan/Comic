//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Detail {
    final class Router {
        weak var vc: Detail.VC?
    }
}

// MARK: - Route to

extension Detail.Router {
    func toReader(comic: Comic.Models.DisplayComic) {
        let to = Reader.VC(comic: comic)
        vc?.navigationController?.pushViewController(to, animated: true)
    }
}
