//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension Reader {
    final class VC: UIViewController {
        var vo = Reader.VO()
        var vm: Reader.VM
        var router = Reader.Router()
        var binding = Set<AnyCancellable>()
        var hideNavbar = true
        var hideStatusBar = false
        
        init(comic: Comic.Models.DisplayComic) {
            self.vm = .init(comic: comic)
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func loadView() {
            view = vo.mainView
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupSelf()
            setupBinding()
            setupVO()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            if vm.imgs.isEmpty {
                vm.doAction(.loadData)
            }
            else {
                hideNavbar = true
                updateUI(delay: true)
            }
        }
        
        override var prefersHomeIndicatorAutoHidden: Bool {
            true
        }
        
        override var prefersStatusBarHidden: Bool {
            hideStatusBar
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Reader.VC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.reuseCell(Reader.Views.Cell.self, for: indexPath)
        let uri = vm.imgs[indexPath.row]
        cell.reloadUI(uri: uri)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension Reader.VC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        hideNavbar.toggle()
        updateUI(delay: false)
    }
}

extension Reader.VC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}

// MARK: - Setup Something

private extension Reader.VC {
    func setupSelf() {
        title = vm.episode?.title
        router.vc = self
    }
    
    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }
            
            switch state {
            case .none:
                self?.stateNone()
            case .showLoading:
                self?.stateShowLoading()
            case .hideLoading:
                self?.stateHideLoading()
            case let .showError(message):
                self?.stateShowError(message: message)
            case .loadedData:
                self?.stateLoadedData()
            }
        }.store(in: &binding)
    }
    
    func setupVO() {
        vo.list.delegate = self
        vo.list.dataSource = self
    }
}

// MARK: - Handle State

private extension Reader.VC {
    func stateNone() {}
    
    func stateShowLoading() {
        let alert = UIAlertController(title: "載入中...", message: nil, preferredStyle: .alert)
        
        let loading = UIActivityIndicatorView(style: .medium)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.startAnimating()
        
        alert.view.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 40),
            loading.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
        ])
        
        present(alert, animated: false)
    }
    
    func stateHideLoading() {
        if let alert = presentedViewController as? UIAlertController {
            alert.dismiss(animated: false)
        }
    }
    
    func stateShowError(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "確定", style: .cancel)
        alert.addAction(cancel)
        
        present(alert, animated: false)
    }
    
    func stateLoadedData() {
        if !vm.imgs.isEmpty {
            hideNavbar = true
            updateUI(delay: true)
        }
        
        vo.reloadList(isEmpty: vm.imgs.isEmpty)
    }
}

// MARK: - Update Something

private extension Reader.VC {
    func updateUI(delay: Bool) {
        navigationController?.setNavigationBarHidden(hideNavbar, animated: true)
        let time = delay ? 0.2 : 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.hideStatusBar = self.hideNavbar
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
