//
//  ReaderVC.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import Combine
import UIKit

final class ReaderVC: UIViewController {
    let vo = ReaderVO()
    let vm: ReaderVM
    let router = ReaderRouter()
    var binding: Set<AnyCancellable> = .init()
    var hideNavbar = false
    var hideStatusBar = false
    var shouldLoadPrev = false
    var shouldLoadNext = false

    var horizontalRead = true {
        didSet {
            updateListLayout()
        }
    }

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
        horizontalRead = true
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        LoadingView.show()
        vm.doAction(.loadData)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        navigationController?.toolbarItems = nil
    }

    override var prefersStatusBarHidden: Bool {
        hideStatusBar
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
            if self?.viewIfLoaded?.window == nil { return }

            switch state {
            case .none:
                self?.stateNone()
            case .dataLoaded:
                self?.stateDataLoaded()
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

    func updateUI(delay: Bool) {
        navigationController?.setNavigationBarHidden(hideNavbar, animated: true)
        navigationController?.setToolbarHidden(hideNavbar, animated: true)
        let time = delay ? 0.2 : 0.0

        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.hideStatusBar = self.hideNavbar
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    func updateListLayout() {
        let layout = horizontalRead ? makeHorizontalLayout() : makeVerticalLayout()
        vo.list.setCollectionViewLayout(layout, animated: false)
        layout.invalidateLayout()
        vo.list.reloadData()
    }

    // MARK: - Handle State

    func stateNone() {}

    func stateDataLoaded() {
        LoadingView.hide()
        navigationItem.title = vm.model.currentEpisode.title
        contentUnavailableConfiguration = nil
        hideNavbar = !vm.model.images.isEmpty
        vo.reloadUI(model: vm.model)

        updateUI(delay: true)

        if vm.model.images.isEmpty {
            hideNavbar = false
            vo.mainView.isHidden = true
            contentUnavailableConfiguration = Self.makeEmpty()
        }
        else {
            contentUnavailableConfiguration = nil
        }
    }

    // MARK: - Make Something

    func makeVerticalLayout() -> UICollectionViewFlowLayout {
        let result = UICollectionViewFlowLayout()
        result.scrollDirection = .vertical
        result.minimumLineSpacing = 0
        result.minimumInteritemSpacing = 0
        vo.list.isPagingEnabled = false
        vo.list.alwaysBounceVertical = true
        vo.list.alwaysBounceHorizontal = false

        return result
    }

    func makeHorizontalLayout() -> UICollectionViewFlowLayout {
        let result = UICollectionViewFlowLayout()
        result.scrollDirection = .horizontal
        result.minimumLineSpacing = 0
        result.minimumInteritemSpacing = 0
        vo.list.isPagingEnabled = true
        vo.list.alwaysBounceVertical = false
        vo.list.alwaysBounceHorizontal = true

        return result
    }

    func makeReloadAction() -> UIAction {
        .init { [weak self] _ in
            guard let self else { return }
            vo.mainView.isHidden = true
            LoadingView.show()
            vm.doAction(.loadData)
        }
    }

    func makeReaderDirectionAction() -> UIAction {
        let title: String = horizontalRead ? "直式閱讀" : "橫向閱讀"

        return .init(title: title) { [weak self] _ in
            guard let self else { return }
            horizontalRead.toggle()
        }.setup(\.attributes, value: .disabled)
    }

    func makeEpisodePickAction() -> UIAction {
        .init(title: "選取集數", image: .init(systemName: "list.number")) { [weak self] _ in
            guard let self else { return }
            router.showEpisodePicker(comic: vm.model.comic)
        }
    }

    func makeFaveriteAction() -> UIAction {
        let title: String = vm.model.comic.favorited ? "取消收藏" : "加入收藏"
        let image: UIImage? = vm.model.comic.favorited ? .init(systemName: "star.fill") : .init(systemName: "star")

        return .init(title: title, image: image) { [weak self] _ in
            guard let self else { return }
            vm.model.comic.favorited.toggle()
        }
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

    // MARK: - Do Something

    func doLoadPrev() {
        LoadingView.show()
        vo.reloadDisableAll()
        vm.doAction(.loadPrev)
    }

    func doLoadNext() {
        LoadingView.show()
        vo.reloadDisableAll()
        vm.doAction(.loadNext)
    }

    func doLoadEpisode(_ episode: Comic.Episode) {
        if episode.id == vm.model.comic.watchedId {
            return
        }

        LoadingView.show()
        vo.reloadDisableAll()
        vm.doAction(.loadEpidoe(episode))
    }
}

// MARK: - UICollectionViewDataSource

extension ReaderVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.model.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reuseCell(ReaderCell.self, for: indexPath)
        let item = vm.model.images[indexPath.row]
        cell.reloadUI(item: item)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ReaderVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        hideNavbar.toggle()
        updateUI(delay: false)
    }
}

// MARK: - UIScrollViewDelegate

extension ReaderVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shouldLoadPrev, vo.prevItem.isEnabled {
            shouldLoadPrev = false
            doLoadPrev()
        }

        if shouldLoadNext, vo.nextItem.isEnabled {
            shouldLoadNext = false
            doLoadNext()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging { return }

        let frame = scrollView.frame
        let contentSize = scrollView.contentSize

        switch horizontalRead {
        case true:
            shouldLoadPrev = scrollView.contentOffset.x < -vo.prevLabel.frame.width
            shouldLoadNext = scrollView.contentOffset.x + frame.width > contentSize.width + vo.nextLabel.frame.width
        case false:
            shouldLoadPrev = scrollView.contentOffset.y < -vo.prevLabel.frame.height
            shouldLoadNext = scrollView.contentOffset.y + frame.height > contentSize.height + vo.nextLabel.frame.height
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReaderVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
        /*
         var result = collectionView.frame.size

         switch horizontalRead {
         case true:
             return result
         case false:
             return result
         }*/
    }
}

// MARK: - EpisodeListModels.SelectedDelegate

extension ReaderVC: EpisodeListModels.SelectedDelegate {
    func episodeList(list: EpisodeListVC, selected episode: Comic.Episode) {
        list.dismiss(animated: true) {
            self.doLoadEpisode(episode)
        }
    }
}
