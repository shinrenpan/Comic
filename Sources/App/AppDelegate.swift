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
        setupBinding()
        setupAppearance()
    }
    
    // MARK: - Setup Something

    private func setupBinding() {
        NotificationCenter.default.addObserver(forName: .showLoading, object: nil, queue: .main) { [weak self] notify in
            LoadingView.hide()

            guard let self else { return }

            guard let loadingView = notify.object as? LoadingView else {
                return
            }

            showLoadingView(view: loadingView)
        }
    }

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
    
    // MARK: - Show Something

    private func showLoadingView(view: LoadingView) {
        guard let window else { return }

        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: window.topAnchor),
            view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
        ])
    }
    
    // MARK: - Make Something

    private func makeRootVC() -> UIViewController {
        let result = CustomTab.ViewController()

        let updateVC = Update.ViewController()
        updateVC.tabBarItem = .init(title: "更新列表", image: .init(systemName: "list.bullet"), tag: 0)

        let favoriteVC = Favorite.ViewController()
        favoriteVC.tabBarItem = .init(title: "收藏列表", image: .init(systemName: "star"), tag: 1)

        let historyVC = History.ViewController()
        historyVC.tabBarItem = .init(title: "觀看紀錄", image: .init(systemName: "clock"), tag: 2)

        let settingVC = Setting.ViewController()
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
