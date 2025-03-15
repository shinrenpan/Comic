//
//  Model.swift
//  EpisodePicker
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit
import DataBase

public protocol Delegate: UIViewController {
    func picker(picker: ViewController, selected episodeId: String)
}

typealias DataSource = UICollectionViewDiffableDataSource<Int, Episode>
typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Episode>
typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode>

enum Action {
    case loadData
}

enum State {
    case none
    case dataLoaded(response: DataLoadedResponse)
}

struct DataLoadedResponse {
    let episodes: [Episode]
}

struct Episode: Hashable {
    let id: String
    let title: String
    let selected: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(epidose: DataBase.Episode, selected: Bool) {
        self.id = epidose.id
        self.title = epidose.title
        self.selected = selected
    }
}
