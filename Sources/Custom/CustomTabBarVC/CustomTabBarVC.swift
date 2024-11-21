//
//  CustomTabBarVC.swift
//
//  Created by Joe Pan on 2024/10/24.
//

import UIKit

final class CustomTabBarVC: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // iOS 18 設成 compact 才會長在下面
        traitOverrides.horizontalSizeClass = .compact
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tapSameTab = selectedViewController?.tabBarItem == item
        
        if tapSameTab, let topVC = getCurrentTopVC() as? ScrollToTopable {
            topVC.scrollToTop()
        }
    }
    
    // MARK: - Get Something
    
    private func getCurrentTopVC() -> UIViewController? {
        if let selectedViewController = selectedViewController as? UINavigationController {
            return selectedViewController.topViewController
        }
        
        return selectedViewController
    }
}
