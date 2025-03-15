//
//  ViewController.swift
//  EpisodePicker
//
//  Created by Joe Pan on 2025/3/5.
//

import UIKit

public final class ViewController: UIViewController {
    private let vo = ViewOutlet()
    private let vm: ViewModel
    private let router = Router()
    private lazy var dataSource = makeDataSource()
    public weak var delegate: Delegate?
    
    public init(comicId: String, episodeId: String) {
        self.vm = .init(comicId: comicId, epidoseId: episodeId)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.doAction(.loadData)
    }
}

// MARK: - Private

private extension ViewController {
    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor
        navigationItem.title = "集數"
        router.vc = self
    }
    
    func setupBinding() {
        _ = withObservationTracking {
            vm.state
        } onChange: { [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                if viewIfLoaded?.window == nil { return }
                
                switch vm.state {
                case .none:
                    stateNone()
                case let .dataLoaded(response):
                    stateDataLoaded(response: response)
                }
                
                setupBinding()
            }
        }
    }
    
    func setupVO() {
        view.addSubview(vo.mainView)
        
        NSLayoutConstraint.activate([
            vo.mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vo.mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vo.mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vo.mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        vo.list.delegate = self
    }
    
    // MARK: - Handle State
    
    func stateNone() {}
    
    func stateDataLoaded(response: DataLoadedResponse) {
        let episodes = response.episodes
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(episodes, toSection: 0)
        snapshot.reloadSections([0])
        
        dataSource.apply(snapshot) { [weak self] in
            guard let self else { return }
            
            showEmptyContent(isEmpty: episodes.isEmpty)
            vo.scrollListToWatched(indexPath: getWatchedIndexPath())
        }
    }
    
    // MARK: - Make Something
    
    func makeCell() -> CellRegistration {
        .init { cell, _, episode in
            var config = UIListContentConfiguration.cell()
            config.text = episode.title
            cell.contentConfiguration = config
            cell.accessories = episode.selected ? [.checkmark()] : []
        }
    }
    
    func makeDataSource() -> DataSource {
        let cell = makeCell()
        
        return .init(collectionView: vo.list) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: itemIdentifier)
        }
    }
    
    // MARK: - Get Something
    
    func getWatchedIndexPath() -> IndexPath? {
        if dataSource.snapshot().itemIdentifiers.isEmpty {
            return nil
        }
        
        let items = dataSource.snapshot().itemIdentifiers
        
        guard let index = items.firstIndex(where: { $0.selected }) else {
            return nil
        }
        
        return .init(item: index, section: 0)
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let episode = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        delegate?.picker(picker: self, selected: episode.id)
    }
}
