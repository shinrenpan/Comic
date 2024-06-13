//
//  AppDelegate.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

@main
class AppDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupAppearance()

        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        window.backgroundColor = .white
        window.rootViewController = makeRootVC()
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

// MARK: - Private

extension AppDelegate {
    // MARK: Setup Something

    func setupAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance.copy()
        UINavigationBar.appearance().compactAppearance = navAppearance.copy()
        UINavigationBar.appearance().compactScrollEdgeAppearance = navAppearance.copy()

        let barAppearance = UITabBarAppearance()
        barAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = barAppearance
        UITabBar.appearance().scrollEdgeAppearance = barAppearance.copy()
    }

    // MARK: - Make Something

    func makeRootVC() -> UIViewController {
        let result = TabBarController()

        let updateVC = UpdateListVC()
        updateVC.tabBarItem = .init(title: "更新列表", image: .init(systemName: "list.bullet"), tag: 0)

        let searchList = SearchListVC()
        searchList.tabBarItem = .init(title: "搜尋", image: .init(systemName: "magnifyingglass"), tag: 1)

        let favoriteVC = FavoriteListVC()
        favoriteVC.tabBarItem = .init(title: "收藏列表", image: .init(systemName: "star"), tag: 2)

        let historyVC = HistoryListVC()
        historyVC.tabBarItem = .init(title: "觀看紀錄", image: .init(systemName: "clock"), tag: 3)

        let settingVC = SettingVC()
        settingVC.tabBarItem = .init(title: "設置", image: .init(systemName: "gear"), tag: 4)

        result.viewControllers = [
            UINavigationController(rootViewController: updateVC),
            UINavigationController(rootViewController: searchList),
            UINavigationController(rootViewController: favoriteVC),
            UINavigationController(rootViewController: historyVC),
            UINavigationController(rootViewController: settingVC),
        ]

        return result
    }
}
