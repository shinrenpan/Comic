//
//  UIViewController+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension UIViewController {
    static func makeEmpty(text: String = "空空如也") -> UIContentUnavailableConfiguration {
        var result = UIContentUnavailableConfiguration.empty()
        result.background.backgroundColor = .white
        result.text = text
        result.textProperties.font = .preferredFont(forTextStyle: .title1)
        result.textProperties.color = .lightGray

        return result
    }

    static func makeError() -> UIContentUnavailableConfiguration {
        var result = UIContentUnavailableConfiguration.empty()
        result.background.backgroundColor = .white
        result.image = UIImage(systemName: "exclamationmark.circle.fill")
        result.text = "發生錯誤."
        result.textProperties.font = .preferredFont(forTextStyle: .title1)
        result.textProperties.color = .lightGray
        result.secondaryText = "重新載入?"
        result.secondaryTextProperties.font = .preferredFont(forTextStyle: .headline)
        result.secondaryTextProperties.color = .lightGray

        var button = UIButton.Configuration.borderless()
        button.image = UIImage(systemName: "arrow.clockwise.circle.fill")
        result.button = button

        return result
    }
}
