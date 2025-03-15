//
//  Cell.swift
//  Reader
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import Kingfisher
import Extensions

final class Cell: UICollectionViewCell {
    let imgView = UIImageView()
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.contentMode, value: .scaleAspectFit)
    
    let modifier = AnyModifier { request in
        var result = request
        result.setValue(.UserAgent.safari.value, forHTTPHeaderField: "User-Agent")
        result.setValue("https://tw.manhuagui.com", forHTTPHeaderField: "Referer")
        return result
    }
    
    var callback: ((UIImage) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupSelf()
        addViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Internal

extension Cell {
    func reloadUI(uri: String) {
        imgView.kf.indicatorType = .custom(indicator: CellIndicator())
        
        imgView.kf.setImage(
            with: URL(string: uri),
            options: [
                .requestModifier(modifier),
                .processor(DownsamplingImageProcessor(size: imgView.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]) { [weak self] result in
                guard let self else { return }
                if case let .success(value) = result {
                    callback?(value.image)
                }
            }
    }
}

// MARK: - Private

private extension Cell {
    private func setupSelf() {
        backgroundColor = .white
    }
    
    private func addViews() {
        contentView.addSubview(imgView)

        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
