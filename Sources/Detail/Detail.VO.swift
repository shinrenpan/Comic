//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Detail {
    final class VO {
        lazy var mainView = makeMainView()
        lazy var headerView = makeHeaderView()
        lazy var list = makeList()
        
        init() {
            addHeaderView()
            addList()
        }
    }
}

// MARK: - Reload Somethig

extension Detail.VO {
    func reloadUI(comic: Comic.Models.DisplayComic) {
        headerView.isHidden = false
        headerView.reloadUI(comic: comic)
        
        let empty = comic.detail?.episodes.isEmpty ?? true
        list.backgroundView = empty ? makeEmptyLabel() : nil
        list.reloadData()
    }
}

// MARK: - Add Something

private extension Detail.VO {
    func addHeaderView() {
        mainView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func addList() {
        mainView.addSubview(list)
        NSLayoutConstraint.activate([
            list.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            list.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor),
            list.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor),
            list.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - Make Something

private extension Detail.VO {
    func makeMainView() -> UIView {
        let result = UIView(frame: .zero)
        result.backgroundColor = .white
        return result
    }
    
    func makeHeaderView() -> Detail.Views.HeaderView {
        let result = Detail.Views.HeaderView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .white
        result.isHidden = true
        return result
    }
    
    func makeList() -> UITableView {
        let result = UITableView(frame: .zero, style: .plain)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.rowHeight = 60
        result.registerCell(UITableViewCell.self)
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
