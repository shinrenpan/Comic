//
//  LoadingView.swift
//
//  Created by Shinren Pan on 2024/7/8.
//

import UIKit

final class LoadingView: UIView {
    init(text: String = "Loading...") {
        super.init(frame: .zero)
        setupSelf()
        setupBinding()
        addViews(text: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension LoadingView {
    static func show(text: String = "Loading...") {
        let loadingView = LoadingView(text: text)
        NotificationCenter.default.post(name: .showLoading, object: loadingView)
    }

    static func hide() {
        NotificationCenter.default.post(name: .hideLoading, object: nil)
    }
}

// MARK: - Private

private extension LoadingView {
    // MARK: Setup Something

    func setupSelf() {
        backgroundColor = .black.withAlphaComponent(0.5)
    }

    func setupBinding() {
        NotificationCenter.default.addObserver(forName: .hideLoading, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            removeFromSuperview()
        }
    }

    // MARK: - Add Something

    func addViews(text: String) {
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
