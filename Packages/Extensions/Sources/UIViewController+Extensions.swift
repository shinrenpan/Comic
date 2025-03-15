//
//  UIViewController+Extensions.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

public extension UIViewController {
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

final class LoadingView: UIView {
    init(text: String = "Loading...") {
        super.init(frame: .zero)
        setupSelf()
        addViews(text: text)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LoadingView {
    private func setupSelf() {
        backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    // MARK: - Add Something
    
    private func addViews(text: String) {
        let loading = UIActivityIndicatorView(style: .large)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.color, value: .white)
        
        let label = UILabel(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.font, value: .preferredFont(forTextStyle: .headline))
            .setup(\.textColor, value: .white)
            .setup(\.textAlignment, value: .center)
            .setup(\.text, value: text)
        
        let vStack = UIStackView(arrangedSubviews: [loading, label])
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.axis, value: .vertical)
            .setup(\.spacing, value: 8)
            .setup(\.alignment, value: .center)
        
        addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        loading.startAnimating()
    }
}
