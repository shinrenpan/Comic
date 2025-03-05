//
//  Router.swift
//  Setting
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit

@MainActor final class Router {
    weak var vc: ViewController?
}

// MARK: - Internal

extension Router {
    func showMenuForSetting(setting: SettingItem, actions: [UIAlertAction], cell: UICollectionViewCell?) {
        let sheet = UIAlertController(
            title: "清除\(setting.title)",
            message: "是否確定清除\(setting.title)",
            preferredStyle: .actionSheet
        )

        sheet.popoverPresentationController?.sourceView = cell
        sheet.popoverPresentationController?.permittedArrowDirections = .up

        for action in actions {
            sheet.addAction(action)
        }

        vc?.present(sheet, animated: true)
    }
}
