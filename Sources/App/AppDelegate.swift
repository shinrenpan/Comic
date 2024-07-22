//
//  AppDelegate.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit

@main
class AppDelegate: UIResponder {
    var window: UIWindow?

    override init() {
        super.init()
        setupBinding()
        setupAppearance()
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

// MARK: - Private

private extension AppDelegate {
    // MARK: Setup Something

    func setupBinding() {
        NotificationCenter.default.addObserver(forName: .showLoading, object: nil, queue: .main) { [weak self] notify in
            LoadingView.hide()

            guard let self else { return }

            guard let loadingView = notify.object as? LoadingView else {
                return
            }

            showLoadingView(view: loadingView)
        }
    }

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

    // MARK: - Show Something

    func showLoadingView(view: LoadingView) {
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

    func makeRootVC() -> UIViewController {
        let result = TabBarController()

        let updateVC = UpdateListVC()
        updateVC.tabBarItem = .init(title: "更新列表", image: .init(systemName: "list.bullet"), tag: 0)

        let favoriteVC = FavoriteListVC()
        favoriteVC.tabBarItem = .init(title: "收藏列表", image: .init(systemName: "star"), tag: 1)

        let historyVC = HistoryListVC()
        historyVC.tabBarItem = .init(title: "觀看紀錄", image: .init(systemName: "clock"), tag: 2)

        let settingVC = SettingVC()
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
