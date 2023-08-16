//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Favorite {
    final class VO {
        lazy var mainView = makeMainView()
        lazy var list = makeList()
        
        init() {
            addList()
        }
    }
}

// MARK: - Reload Something

extension Favorite.VO {
    func reloadList(isEmpty: Bool) {
        list.backgroundView = isEmpty ? makeEmptyLabel() : nil
        list.reloadData()
    }
}

// MARK: - Add Something

private extension Favorite.VO {
    func addList() {
        mainView.addSubview(list)
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: mainView.topAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
        ])
    }
}

// MARK: - Make Something

private extension Favorite.VO {
    func makeMainView() -> UIView {
        let result = UIView(frame: .zero)
        result.backgroundColor = .white
        return result
    }
    
    func makeList() -> UITableView {
        let result = UITableView(frame: .zero, style: .plain)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.registerCell(Favorite.Views.Cell.self)
        result.rowHeight = UITableView.automaticDimension
        result.estimatedRowHeight = 60
        result.separatorInset = .init(top: 0, left: 90, bottom: 0, right: 0)
        return result
    }
    
    func makeEmptyLabel() -> UILabel {
        let result = UILabel(frame: .zero)
        result.textColor = .lightGray
        result.textAlignment = .center
        result.font = .preferredFont(forTextStyle: .largeTitle)
        result.text = "空空如也"
        return result
    }
}
