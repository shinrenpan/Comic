//
//  TabBarController.swift
//
//  Created by Shinren Pan on 2024/5/29.
//

import UIKit

protocol ScrollToTopable: UIViewController {
    func scrollToTop()
}

final class TabBarController: UITabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let sameTab = selectedViewController?.tabBarItem == item

        if sameTab, let topVC = getCurrentTopVC() as? ScrollToTopable {
            topVC.scrollToTop()
        }
    }
}

// MARK: - Private

private extension TabBarController {
    func getCurrentTopVC() -> UIViewController? {
        if let selectedViewController = selectedViewController as? UINavigationController {
            return selectedViewController.topViewController
        }

        return selectedViewController
    }
}
