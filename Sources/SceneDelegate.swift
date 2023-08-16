//
// Copyright (c) 2023 Shinren Pan
//

import UIKit
import WebParser

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIWindowSceneDelegate

extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        window.backgroundColor = .white
        setupNavigationController()
        setupTabBarController()
        window.rootViewController = makeRootVC()
        self.window = window
        window.makeKeyAndVisible()
    }
}

// MARK: - Setup Something

private extension SceneDelegate {
    func setupNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance.copy()
        UINavigationBar.appearance().compactAppearance = appearance.copy()
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance.copy()
    }
    
    func setupTabBarController() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance.copy()
    }
}

// MARK: - Make Something

private extension SceneDelegate {
    func makeRootVC() -> UITabBarController {
        let result = UITabBarController()
        result.viewControllers = [
            UINavigationController(rootViewController: makeUpdateVC()),
            UINavigationController(rootViewController: makeFavoriteVC()),
            UINavigationController(rootViewController: makeHistoryVC()),
        ]
        
        return result
    }
    
    func makeUpdateVC() -> Update.VC {
        let result = Update.VC()
        result.tabBarItem = .init(title: "更新列表", image: .init(systemName: "list.bullet"), tag: 0)
        return result
    }
    
    func makeFavoriteVC() -> Favorite.VC {
        let result = Favorite.VC()
        result.tabBarItem = .init(title: "收藏列表", image: .init(systemName: "star.fill"), tag: 0)
        return result
    }
    
    func makeHistoryVC() -> History.VC {
        let result = History.VC()
        result.tabBarItem = .init(title: "觀看紀錄", image: .init(systemName: "clock"), tag: 0)
        return result
    }
}
