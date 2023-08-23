//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 點中同一個 Index
        if selectedViewController === viewController {
            scrollToTop(vc: viewController)
        }
        
        return true
    }
}

// MARK: - Private Functions

private extension TabBarController {
    func scrollToTop(vc: UIViewController) {
        guard let nav = vc as? UINavigationController else {
            return
        }
        
        guard let topVC = nav.topViewController as? TabScrollableVC else {
            return
        }
        
        let scrollView = topVC.scrollView
        scrollView.setContentOffset(.init(x: 0, y: 0 - scrollView.adjustedContentInset.top), animated: true)
    }
}
