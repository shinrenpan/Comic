//
//  TabBarController.swift
//  CustomUI
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit

public final class TabBarController: UITabBarController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        // iOS 18 設成 compact 才會長在下面
        traitOverrides.horizontalSizeClass = .compact
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tapSameTab = selectedViewController?.tabBarItem == item
        
        if tapSameTab, let topVC = getCurrentTopVC() as? ScrollToTopable {
            topVC.scrollToTop()
        }
    }
}

// MARK: - Public

public extension TabBarController {
    protocol ScrollToTopable: UIViewController {
        func scrollToTop()
    }
}

// MARK: - Private

private extension TabBarController {
    // MARK: - Get Something
    
    private func getCurrentTopVC() -> UIViewController? {
        if let selectedViewController = selectedViewController as? UINavigationController {
            return selectedViewController.topViewController
        }
        
        return selectedViewController
    }
}
