//
//  AppDelegate.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebKit

@main class AppDelegate: UIResponder {
    var window: UIWindow?

    override init() {
        super.init()
        doCleanCookies()
        setupAppearance()
    }
    
    // MARK: - Setup Something

    private func setupAppearance() {
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

    // MARK: - Do Something
    
    private func doCleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    // MARK: - Make Something

    private func makeRootVC() -> UIViewController {
        let result = CustomTab.ViewController()

        let updateVC = Update.VC()
        updateVC.tabBarItem = .init(title: "更新列表", image: .init(systemName: "list.bullet"), tag: 0)

        let favoriteVC = Favorite.VC()
        favoriteVC.tabBarItem = .init(title: "收藏列表", image: .init(systemName: "star"), tag: 1)

        let historyVC = History.VC()
        historyVC.tabBarItem = .init(title: "觀看紀錄", image: .init(systemName: "clock"), tag: 2)

        let settingVC = Setting.VC()
        settingVC.tabBarItem = .init(title: "設置", image: .init(systemName: "gear"), tag: 3)

        result.viewControllers = [
            UINavigationController(rootViewController: updateVC),
            UINavigationController(rootViewController: favoriteVC),
            UINavigationController(rootViewController: historyVC),
            UINavigationController(rootViewController: settingVC),
        ]

        return result
    }
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        window.backgroundColor = .white
        window.rootViewController = makeRootVC()
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
