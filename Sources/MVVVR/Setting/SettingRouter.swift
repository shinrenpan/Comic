//
//  SettingRouter.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

extension Setting {
    final class Router {
        weak var vc: ViewController?
        
        // MARK: - Public
        
        func showMenuForSetting(setting: DisplaySetting, actions: [UIAlertAction], cell: UICollectionViewCell?) {
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
}
