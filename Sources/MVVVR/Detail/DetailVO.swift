//
//  DetailVO.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

final class DetailVO {
    let mainView = UIView(frame: .zero)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let header = DetailHeader()
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)
        .setup(\.backgroundColor, value: .white)

    let list = UITableView(frame: .zero, style: .plain)
        .setup(\.translatesAutoresizingMaskIntoConstraints, value: false)

    init() {
        setupSelf()
        addViews()
    }
}

// MARK: - Public

extension DetailVO {
    func reloadUI(model: DetailModels.DisplayModel) {
        header.reloadUI(comic: model.comic)
        list.refreshControl?.endRefreshing()
        list.reloadData()
    }
}

// MARK: - Private

private extension DetailVO {
    // MARK: Setup Something

    func setupSelf() {
        list.registerCell(UITableViewCell.self)
        list.refreshControl = .init(frame: .zero)
    }

    // MARK: - Add Something

    func addViews() {
        mainView.addSubview(header)
        mainView.addSubview(list)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: mainView.topAnchor),
            header.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),

            list.topAnchor.constraint(equalTo: header.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
        ])
    }
}
