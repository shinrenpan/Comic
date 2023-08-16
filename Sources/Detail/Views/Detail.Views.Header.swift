//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Detail.Views {
    final class HeaderView: UIView {
        lazy var coverView = makeCoverView()
        lazy var titleLabel = makeTitleLabel()
        lazy var authorLabel = makeAuthorLabel()
        lazy var descLabel = makeDescLabel()
        
        init() {
            super.init(frame: .zero)
            addContainer()
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
            addGestureRecognizer(tap)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Reload Something

extension Detail.Views.HeaderView {
    func reloadUI(comic: Comic.Models.DisplayComic) {
        titleLabel.text = comic.title
        authorLabel.text = comic.detail?.author
        descLabel.text = comic.detail?.desc
        coverView.loadImage(uri: "https:\(comic.imageURI)", holder: nil)
    }
}

// MARK: - Add Something

private extension Detail.Views.HeaderView {
    func addContainer() {
        let container = makeContainer()
        
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - Make Something

private extension Detail.Views.HeaderView {
    func makeCoverView() -> UIImageView {
        let result = UIImageView(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .lightGray
        result.widthAnchor.constraint(equalToConstant: 70).isActive = true
        result.heightAnchor.constraint(equalToConstant: 90).isActive = true
        return result
    }
    
    func makeTitleLabel() -> UILabel {
        let result = UILabel(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 2
        result.font = .preferredFont(forTextStyle: .headline)
        return result
    }
    
    func makeAuthorLabel() -> UILabel {
        let result = UILabel(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = .preferredFont(forTextStyle: .subheadline)
        return result
    }
    
    func makeDescLabel() -> UILabel {
        let result = UILabel(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 4
        result.font = .preferredFont(forTextStyle: .footnote)
        return result
    }
    
    func makeContainer() -> UIStackView {
        let labels = makeLabelsStack()
        
        let result = UIStackView(arrangedSubviews: [
            coverView,
            labels
        ])
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.spacing = 8
        result.alignment = .top
        result.isLayoutMarginsRelativeArrangement = true
        result.layoutMargins = .init(top: 4, left: 8, bottom: 16, right: 8)
        return result
    }
    
    func makeLabelsStack() -> UIStackView {
        let result = UIStackView(arrangedSubviews: [
            titleLabel,
            authorLabel,
            descLabel
        ])
        
        result.axis = .vertical
        result.spacing = 6
        result.setCustomSpacing(20, after: authorLabel)
        return result
    }
}

// MARK: - Target / Action

private extension Detail.Views.HeaderView {
    @objc func tapSelf() {
        descLabel.numberOfLines = descLabel.numberOfLines > 4 ? 4 : 8
    }
}
