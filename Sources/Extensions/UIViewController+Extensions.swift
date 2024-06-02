//
//  UIViewController+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension UIViewController {
    func showEmptyUI(isEmpty: Bool) {
        switch isEmpty {
        case true:
            var config = UIContentUnavailableConfiguration.empty()
            config.background.backgroundColor = .white
            config.text = "空空如也"
            config.textProperties.font = .preferredFont(forTextStyle: .title1)
            config.textProperties.color = .lightGray
            contentUnavailableConfiguration = config
        case false:
            contentUnavailableConfiguration = nil
        }
    }

    func showLoadingUI() {
        var config = UIContentUnavailableConfiguration.loading()
        config.text = ""

        contentUnavailableConfiguration = config
    }

    func showErrorUI(reload: UIAction?) {
        var config = UIContentUnavailableConfiguration.empty()
        config.background.backgroundColor = .white
        config.image = UIImage(systemName: "exclamationmark.circle.fill")
        config.text = "Something went wrong."
        config.textProperties.font = .preferredFont(forTextStyle: .title1)
        config.textProperties.color = .lightGray
        config.secondaryText = "Please try again later."
        config.secondaryTextProperties.font = .preferredFont(forTextStyle: .headline)
        config.secondaryTextProperties.color = .lightGray

        var button = UIButton.Configuration.borderless()
        button.image = UIImage(systemName: "arrow.clockwise.circle.fill")
        config.button = button
        config.buttonProperties.primaryAction = reload

        contentUnavailableConfiguration = config
    }
}
