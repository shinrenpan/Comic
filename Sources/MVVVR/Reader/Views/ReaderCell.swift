//
//  ReaderCell.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Kingfisher
import UIKit

final class ReaderCell: UICollectionViewCell {
    let imgView = UIImageView()
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.contentMode, value: .scaleAspectFit)

    let modifier = AnyModifier { request in
        var result = request
        result.setValue(.UserAgent.safari.value, forHTTPHeaderField: "User-Agent")
        result.setValue("https://tw.manhuagui.com", forHTTPHeaderField: "Referer")
        return result
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension ReaderCell {
    func reloadUI(item: Comic.ImageData) {
        imgView.kf.indicatorType = .custom(indicator: ReaderCellIndicator())

        imgView.kf.setImage(
            with: URL(string: item.uri),
            options: [
                .requestModifier(modifier),
                .processor(DownsamplingImageProcessor(size: imgView.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]
        )
    }
}

// MARK: - Private

private extension ReaderCell {
    // MARK: Add Something

    func addViews() {
        contentView.addSubview(imgView)

        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    // MARK: - Make
}
