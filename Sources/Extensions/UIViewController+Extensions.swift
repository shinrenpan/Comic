//
//  UIViewController+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension UIViewController {
    func showLoading(text: String = "Loading...", onWindow: Bool = false) {
        hideLoading()
        
        let loadingView = LoadingView(text: text)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        
        if onWindow, let window = view.window {
            window.addSubview(loadingView)

            NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: window.topAnchor),
                loadingView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            ])
        }
        else {
            view.addSubview(loadingView)

            NSLayoutConstraint.activate([
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }
    
    func hideLoading() {
        for view in view.subviews {
            if let loadingView = view as? LoadingView {
                loadingView.removeFromSuperview()
            }
        }
        
        guard let window = view.window else { return }
        
        for view in window.subviews {
            if let loadingView = view as? LoadingView {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    func showEmptyContent(isEmpty: Bool, text: String = "空空如也") {
        if !isEmpty {
            contentUnavailableConfiguration = nil
            return
        }
        
        var content = UIContentUnavailableConfiguration.empty()
        content.background.backgroundColor = .white
        content.text = text
        content.textProperties.font = .preferredFont(forTextStyle: .title1)
        content.textProperties.color = .lightGray
        contentUnavailableConfiguration = content
    }
    
    func showErrorContent(action: UIAction?) {
        var content = UIContentUnavailableConfiguration.empty()
        content.background.backgroundColor = .white
        content.image = UIImage(systemName: "exclamationmark.circle.fill")
        content.text = "發生錯誤."
        content.textProperties.font = .preferredFont(forTextStyle: .title1)
        content.textProperties.color = .lightGray
        
        var button = UIButton.Configuration.filled()
        button.title = "重新載入"
        content.button = button
        content.buttonProperties.primaryAction = action
        contentUnavailableConfiguration = content
    }
}
