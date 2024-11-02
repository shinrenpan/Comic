//
//  DetailHeader.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Kingfisher
import UIKit

extension Detail {
    final class Header: UIView {
        let coverView = UIImageView(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.backgroundColor, value: .lightGray)
        
        let titleLabel = UILabel(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.font, value: .preferredFont(forTextStyle: .headline))
            .setup(\.numberOfLines, value: 2)
        
        let authorLabel = UILabel(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.font, value: .preferredFont(forTextStyle: .subheadline))
        
        let descLabel = UILabel(frame: .zero)
            .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
            .setup(\.font, value: .preferredFont(forTextStyle: .subheadline))
            .setup(\.numberOfLines, value: 4)
        
        init() {
            super.init(frame: .zero)
            setupSelf()
            addViews()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Public
        
        func reloadUI(comic: DisplayComic) {
            titleLabel.text = comic.title
            authorLabel.text = comic.author
            descLabel.text = comic.description

            coverView.kf.setImage(
                with: URL(string: "https:\(comic.coverURI)"),
                options: [
                    .processor(DownsamplingImageProcessor(size: coverView.frame.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                ]
            )
        }
        
        // MARK: - Setup Something

        private func setupSelf() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
            addGestureRecognizer(tap)
        }

        // MARK: - Add Something

        func addViews() {
            let vStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, descLabel])
                .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
                .setup(\.axis, value: .vertical)
                .setup(\.spacing, value: 4)
                .setup(\.alignment, value: .leading)
            vStack.setCustomSpacing(16, after: authorLabel)

            let hStack = UIStackView(arrangedSubviews: [coverView, vStack])
                .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
                .setup(\.axis, value: .horizontal)
                .setup(\.spacing, value: 8)
                .setup(\.alignment, value: .top)
                .setup(\.isLayoutMarginsRelativeArrangement, value: true)
                .setup(\.layoutMargins, value: .init(top: 4, left: 8, bottom: 20, right: 8))
            addSubview(hStack)

            NSLayoutConstraint.activate([
                coverView.widthAnchor.constraint(equalToConstant: 70),
                coverView.heightAnchor.constraint(equalToConstant: 90),

                hStack.topAnchor.constraint(equalTo: topAnchor),
                hStack.leadingAnchor.constraint(equalTo: leadingAnchor),
                hStack.trailingAnchor.constraint(equalTo: trailingAnchor),
                hStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        // MARK: - Target / Action

        @objc private func tapSelf() {
            let numberOfLines = descLabel.numberOfLines
            descLabel.numberOfLines = numberOfLines > 1 ? 1 : 4
        }
    }
}
