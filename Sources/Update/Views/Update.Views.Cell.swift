//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Update.Views {
    final class Cell: UITableViewCell {
        lazy var coverView = makeCoverView()
        lazy var titleLabel = makeTitleLabel()
        lazy var episodeLabel = makeEpisodeLabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addContainer()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            coverView.cancelLoadImage()
        }
    }
}

// MARK: - Reload Something

extension Update.Views.Cell {
    func reloadUI(comic: Comic.Models.DisplayComic) {
        titleLabel.text = comic.title
        episodeLabel.text = comic.episode
        coverView.loadImage(uri: "https:\(comic.imageURI)", holder: nil)
        contentView.backgroundColor = comic.isFavorite ? .yellow : .white
    }
}

// MARK: - Add Something

private extension Update.Views.Cell {
    func addContainer() {
        let container = makeContainer()
        
        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - Make Something

private extension Update.Views.Cell {
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
    
    func makeEpisodeLabel() -> UILabel {
        let result = UILabel(frame: .zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = .preferredFont(forTextStyle: .subheadline)
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
            episodeLabel,
        ])
        
        result.axis = .vertical
        result.spacing = 6
        result.setCustomSpacing(20, after: episodeLabel)
        return result
    }
}
