//
// Copyright (c) 2023 Shinren Pan
//

import UIKit

extension Reader {
    final class VO {
        lazy var mainView = makeMainView()
        lazy var list = makeList()
        
        init() {
            addList()
        }
    }
}

// MARK: - Reload Somethig

extension Reader.VO {
    func reloadList(isEmpty: Bool) {
        list.backgroundView = isEmpty ? makeEmptyLabel() : nil
        list.reloadData()
    }
}

// MARK: - Add Something

private extension Reader.VO {
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

private extension Reader.VO {
    func makeMainView() -> UIView {
        let result = UIView(frame: .zero)
        result.backgroundColor = .white
        return result
    }
    
    func makeList() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let result = UICollectionView(frame: .zero, collectionViewLayout: layout)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.isPagingEnabled = true
        result.registerCell(Reader.Views.Cell.self)
        result.contentInsetAdjustmentBehavior = .never
        result.insetsLayoutMarginsFromSafeArea = false
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
