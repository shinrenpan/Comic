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
        addViews(text: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Something

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
