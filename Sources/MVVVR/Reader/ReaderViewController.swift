//
//  ReaderVC.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import Observation
import UIKit

extension Reader {
    final class ViewController: UIViewController {
        let vo = ViewOutlet()
        let vm: ViewModel
        let router = Router()
        var hideBar = false
        var readDirection = ReadDirection.horizontal
        
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
        
        // MARK: - Setup Something

        private func setupSelf() {
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

        private func setupBinding() {
            _ = withObservationTracking {
                vm.state
            } onChange: {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if viewIfLoaded?.window == nil { return }
                    
                    switch vm.state {
                    case .none:
                        stateNone()
                    case let .dataLoaded(response):
                        stateDataLoaded(response: response)
                    case let .dataLoadFail(response):
                        stateDataLoadFail(response: response)
                    }
                    
                    setupBinding()
                }
            }
        }

        private func setupVO() {
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

        private func updateHiddenBarUI(delay: Bool) {
            navigationController?.setNavigationBarHidden(hideBar, animated: true)
            navigationController?.setToolbarHidden(hideBar, animated: true)
            
            let time = delay ? 0.2 : 0.0

            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.setNeedsUpdateOfHomeIndicatorAutoHidden()
                self.setNeedsStatusBarAppearanceUpdate()
                self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            }
        }

        private func updateListLayout() {
            let layout = makeListLayout()
            vo.list.setCollectionViewLayout(layout, animated: false)
            layout.invalidateLayout()
            vo.list.reloadData()
        }
        
        // MARK: - Handle State

        private func stateNone() {}

        private func stateDataLoaded(response: DataLoadedResponse) {
            LoadingView.hide()
            navigationItem.title = response.episode.title
            vo.reloadEnableUI(response: response)
            updateHiddenBarUI(delay: true)
            updateListLayout()
            vo.reloadListToStartPosition()
        }
        
        private func stateDataLoadFail(response: ImageLoadFailResponse) {
            LoadingView.hide()
        }
        
        // MARK: - Make Something

        private func makeListLayout() -> UICollectionViewLayout {
            switch readDirection {
            case .horizontal:
                return makeHorizontalListLayout()
            case .vertical:
                return makeVerticalListLayout()
            }
        }
        
        private func makeVerticalListLayout() -> UICollectionViewFlowLayout {
            let result = UICollectionViewFlowLayout()
            result.scrollDirection = .vertical
            result.minimumLineSpacing = 0
            result.minimumInteritemSpacing = 0
            vo.list.isPagingEnabled = false
            vo.list.alwaysBounceVertical = true
            vo.list.alwaysBounceHorizontal = false

            return result
        }

        private func makeHorizontalListLayout() -> UICollectionViewFlowLayout {
            let result = UICollectionViewFlowLayout()
            result.scrollDirection = .horizontal
            result.minimumLineSpacing = 0
            result.minimumInteritemSpacing = 0
            vo.list.isPagingEnabled = true
            vo.list.alwaysBounceVertical = false
            vo.list.alwaysBounceHorizontal = true

            return result
        }

        private func makeMoreItemMenu() -> UIMenu {
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

        private func makeReaderDirectionAction() -> UIAction {
            .init(title: readDirection.toChangeTitle) { [weak self] _ in
                guard let self else { return }
                doChangeReadDirection()
            }
        }
        
        private func makeEpisodePickAction() -> UIAction {
            .init(title: "選取集數", image: .init(systemName: "list.number")) { [weak self] _ in
                guard let self else { return }
                router.showEpisodePicker(comic: vm.comic)
            }
        }
        
        private func makeFaveriteAction() -> UIAction {
            let title: String = vm.comic.favorited ? "取消收藏" : "加入收藏"
            let image: UIImage? = vm.comic.favorited ? .init(systemName: "star.fill") : .init(systemName: "star")

            return .init(title: title, image: image) { [weak self] _ in
                guard let self else { return }
                vm.comic.favorited.toggle()
            }
        }
        
        private func makeRatio(image: UIImage?, maxWidth: CGFloat?) -> CGFloat? {
            guard let image, let maxWidth else {
                return 1
            }
            
            guard image.size.width > 0, image.size.height > 0 else {
                return 1
            }
            
            return maxWidth / image.size.width
        }
        
        // MARK: - Do Something

        private func doLoadPrev() {
            LoadingView.show()
            vo.reloadDisableUI()
            vm.doAction(.loadPrev)
        }

        private func doLoadNext() {
            LoadingView.show()
            vo.reloadDisableUI()
            vm.doAction(.loadNext)
        }

        private func doChangeEpisode(episode: Comic.Episode) {
            if episode.id == vm.comic.watchedId {
                return
            }

            LoadingView.show()
            vo.reloadDisableUI()
            vm.doAction(.loadData(request: .init(epidose: episode)))
        }
        
        private func doChangeReadDirection() {
            vm.imageDatas.forEach { $0.image = nil }
            
            switch readDirection {
            case .horizontal:
                readDirection = .vertical
            case .vertical:
                readDirection = .horizontal
            }
            
            updateListLayout()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Reader.ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.imageDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reuseCell(Reader.Cell.self, for: indexPath)
        let data = vm.imageDatas[indexPath.item]
        
        cell.callback = { image in
            DispatchQueue.main.async {
                data.image = image
                UIView.setAnimationsEnabled(false)
                collectionView.reloadItems(at: [indexPath])
                UIView.setAnimationsEnabled(true)
            }
        }
        
        if let image = data.image {
            cell.imgView.image = image
        }
        else {
            cell.reloadUI(uri: data.uri)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension Reader.ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        hideBar.toggle()
        updateHiddenBarUI(delay: false)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Reader.ViewController: UICollectionViewDelegateFlowLayout {
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

extension Reader.ViewController: EpisodeListModel.SelectedDelegate {
    func episodeList(list: EpisodeListVC, selected episode: Comic.Episode) {
        list.dismiss(animated: true) {
            self.doChangeEpisode(episode: episode)
        }
    }
}
