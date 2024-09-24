//
//  ReaderVC.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import Combine
import UIKit
import Kingfisher

final class ReaderVC: UIViewController {
    let vo = ReaderVO()
    let vm: ReaderVM
    let router = ReaderRouter()
    var binding: Set<AnyCancellable> = .init()
    var hideBar = false
    var readDirection = ReaderModel.ReadDirection.vertical

    init(comic: Comic, episode: Comic.Episode) {
        self.vm = .init(comic: comic, episode: episode)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSelf()
        setupBinding()
        setupVO()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        LoadingView.show()
        vm.doAction(.loadData(request: .init(epidose: nil)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        navigationController?.toolbarItems = nil
    }

    override var prefersStatusBarHidden: Bool {
        hideBar
    }

    // home indicator 變灰
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        .all
    }
}

// MARK: - Private

private extension ReaderVC {
    // MARK: Setup Something

    func setupSelf() {
        view.backgroundColor = vo.mainView.backgroundColor

        setToolbarItems([
            vo.prevItem,
            .init(systemItem: .flexibleSpace),
            vo.moreItem,
            .init(systemItem: .flexibleSpace),
            vo.nextItem,
        ], animated: false)

        router.vc = self
    }

    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            guard let self else { return }
            if viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                stateNone()
            case let .dataLoaded(response):
                stateDataLoaded(response: response)
            case let .dataLoadFail(response):
                stateDataLoadFail(response: response)
            }
        }.store(in: &binding)
    }

    func setupVO() {
        view.addSubview(vo.mainView)

        NSLayoutConstraint.activate([
            vo.mainView.topAnchor.constraint(equalTo: view.topAnchor),
            vo.mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vo.mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vo.mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        vo.list.dataSource = self
        vo.list.delegate = self

        vo.prevItem.primaryAction = .init(title: "上一話") { [weak self] _ in
            guard let self else { return }
            doLoadPrev()
        }

        vo.moreItem.menu = makeMoreItemMenu()

        vo.nextItem.primaryAction = .init(title: "下一話") { [weak self] _ in
            guard let self else { return }
            doLoadNext()
        }
    }

    // MARK: - Update Something

    func updateHiddenBarUI(delay: Bool) {
        navigationController?.setNavigationBarHidden(hideBar, animated: true)
        navigationController?.setToolbarHidden(hideBar, animated: true)
        
        let time = delay ? 0.2 : 0.0

        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    func updateListLayout() {
        let layout = makeListLayout()
        vo.list.setCollectionViewLayout(layout, animated: false)
        layout.invalidateLayout()
        vo.list.reloadData()
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded(response: ReaderModel.DataLoadedResponse) {
        LoadingView.hide()
        navigationItem.title = response.episode.title
        vo.reloadEnableUI(response: response)
        updateHiddenBarUI(delay: true)
        updateListLayout()
    }
    
    func stateDataLoadFail(response: ReaderModel.ImageLoadFailResponse) {
        LoadingView.hide()
    }

    // MARK: - Make Something

    func makeListLayout() -> UICollectionViewLayout {
        switch readDirection {
        case .horizontal:
            return makeHorizontalListLayout()
        case .vertical:
            return makeVerticalListLayout()
        }
    }
    
    func makeVerticalListLayout() -> UICollectionViewFlowLayout {
        let result = UICollectionViewFlowLayout()
        result.scrollDirection = .vertical
        result.minimumLineSpacing = 0
        result.minimumInteritemSpacing = 0
        vo.list.isPagingEnabled = false
        vo.list.alwaysBounceVertical = true
        vo.list.alwaysBounceHorizontal = false

        return result
    }

    func makeHorizontalListLayout() -> UICollectionViewFlowLayout {
        let result = UICollectionViewFlowLayout()
        result.scrollDirection = .horizontal
        result.minimumLineSpacing = 0
        result.minimumInteritemSpacing = 0
        vo.list.isPagingEnabled = true
        vo.list.alwaysBounceVertical = false
        vo.list.alwaysBounceHorizontal = true

        return result
    }

    func makeMoreItemMenu() -> UIMenu {
        let readerDirection = UIDeferredMenuElement.uncached { [weak self] completion in
            guard let self else { return }
            let action = makeReaderDirectionAction()

            DispatchQueue.main.async {
                completion([action])
            }
        }

        let episodePick = makeEpisodePickAction()

        let favorite = UIDeferredMenuElement.uncached { [weak self] completion in
            guard let self else { return }
            let action = makeFaveriteAction()

            DispatchQueue.main.async {
                completion([action])
            }
        }

        return .init(title: "更多...", children: [readerDirection, favorite, episodePick])
    }

    func makeReaderDirectionAction() -> UIAction {
        .init(title: readDirection.toChangeTitle) { [weak self] _ in
            guard let self else { return }
            doChangeReadDirection()
        }
    }
    
    func makeEpisodePickAction() -> UIAction {
        .init(title: "選取集數", image: .init(systemName: "list.number")) { [weak self] _ in
            guard let self else { return }
            router.showEpisodePicker(comic: vm.comic)
        }
    }
    
    func makeFaveriteAction() -> UIAction {
        let title: String = vm.comic.favorited ? "取消收藏" : "加入收藏"
        let image: UIImage? = vm.comic.favorited ? .init(systemName: "star.fill") : .init(systemName: "star")

        return .init(title: title, image: image) { [weak self] _ in
            guard let self else { return }
            vm.comic.favorited.toggle()
        }
    }
    
    func makeRatio(image: UIImage?, maxWidth: CGFloat?) -> CGFloat? {
        guard let image, let maxWidth else {
            return nil
        }
        
        guard image.size.width > 0, image.size.height > 0 else {
            return nil
        }
        
        if image.size.width > maxWidth {
            return maxWidth / image.size.width
        }
        else {
            return image.size.width / maxWidth
        }
    }
    
    // MARK: - Do Something

    func doLoadPrev() {
        LoadingView.show()
        vo.reloadDisableUI()
        vm.doAction(.loadPrev)
    }

    func doLoadNext() {
        LoadingView.show()
        vo.reloadDisableUI()
        vm.doAction(.loadNext)
    }

    func doChangeEpisode(episode: Comic.Episode) {
        if episode.id == vm.comic.watchedId {
            return
        }

        LoadingView.show()
        vo.reloadDisableUI()
        vm.doAction(.loadData(request: .init(epidose: episode)))
    }
    
    func doChangeReadDirection() {
        switch readDirection {
        case .horizontal:
            readDirection = .vertical
        case .vertical:
            readDirection = .horizontal
        }
        
        updateListLayout()
    }
}

// MARK: - UICollectionViewDataSource

extension ReaderVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.imageDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reuseCell(ReaderCell.self, for: indexPath)
        let data = vm.imageDatas[indexPath.item]
        
        cell.callback = {
            if collectionView.indexPathsForVisibleItems.contains(indexPath) {
                UIView.setAnimationsEnabled(false)
                collectionView.reloadItems(at: [indexPath])
                UIView.setAnimationsEnabled(true)
            }
        }
        
        cell.reloadUI(uri: data.uri)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ReaderVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        hideBar.toggle()
        updateHiddenBarUI(delay: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReaderVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var result = collectionView.frame.size
        
        switch readDirection {
        case .horizontal:
            return result
        case .vertical:
            if let image = vm.imageDatas[indexPath.item].image, let ratio = makeRatio(image: image, maxWidth: result.width) {
                // 有小數點會造成產生一條白線
                let height = Int(image.size.height * ratio)
                result.height = CGFloat(height)
            }
            
            return result
        }
    }
}

// MARK: - EpisodeListModels.SelectedDelegate

extension ReaderVC: EpisodeListModel.SelectedDelegate {
    func episodeList(list: EpisodeListVC, selected episode: Comic.Episode) {
        list.dismiss(animated: true) {
            self.doChangeEpisode(episode: episode)
        }
    }
}
