//
//  ReaderVO.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit

extension Reader {
    @MainActor
    final class VO {
        let mainView = UIView(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.backgroundColor, value: .white)
            .setup(\.isHidden, value: false)
        
        let list = UICollectionView(frame: .zero, collectionViewLayout: .init())
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        
        let prevItem = UIBarButtonItem(title: "上一話")
            .setup(\.isEnabled, value: false)
        
        let moreItem = UIBarButtonItem(title: "更多...")
            .setup(\.isEnabled, value: false)
        
        let nextItem = UIBarButtonItem(title: "下一話")
            .setup(\.isEnabled, value: false)
        
        init() {
            setupSelf()
            addViews()
        }
        
        // MARK: - Public
        
        func reloadListToStartPosition() {
            let zero = IndexPath(item: 0, section: 0)
            list.scrollToItem(at: zero, at: .top, animated: false)
        }
        
        func reloadEnableUI(response: DataLoadedResponse) {
            mainView.isHidden = false
            prevItem.isEnabled = response.hasPrev
            moreItem.isEnabled = true
            nextItem.isEnabled = response.hasNext
        }
        
        func reloadDisableUI() {
            mainView.isHidden = true
            prevItem.isEnabled = false
            moreItem.isEnabled = false
            nextItem.isEnabled = false
        }
        
        // MARK: - Setup Something

        private func setupSelf() {
            list.contentInsetAdjustmentBehavior = .never
            list.registerCell(Cell.self)
        }

        // MARK: - Add Something

        private func addViews() {
            mainView.addSubview(list)

            NSLayoutConstraint.activate([
                list.topAnchor.constraint(equalTo: mainView.topAnchor, constant: getStatusBarHeight()),
                list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
                list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
                list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20),
            ])
        }
        
        // MARK: - Get Something
        
        private func getStatusBarHeight() -> CGFloat {
            var result: CGFloat = 0
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            result = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            
            return result
        }
    }
}
