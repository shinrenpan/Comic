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
        
        func showMenuForItem(item: Item, actions: [UIAlertAction], cell: UICollectionViewCell?) {
            let sheet = UIAlertController(
                title: "清除\(item.title)",
                message: "是否確定清除\(item.title)",
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
