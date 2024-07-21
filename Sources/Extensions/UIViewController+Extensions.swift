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
        result.text = "空空如也"
        result.textProperties.font = .preferredFont(forTextStyle: .title1)
        result.textProperties.color = .lightGray

        return result
    }

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

    func showLoadingUI(text: String = "Loading...") {
        var config = UIContentUnavailableConfiguration.loading()
        config.background.backgroundColor = .black.withAlphaComponent(0.5)
        config.imageProperties.tintColor = .white
        config.textProperties.color = .white
        config.text = text

        contentUnavailableConfiguration = config
    }

    func hideLoadingUI() {
        contentUnavailableConfiguration = nil
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
