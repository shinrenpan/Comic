//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension Detail {
    final class VC: UIViewController {
        var vo = Detail.VO()
        var vm: Detail.VM
        var router = Detail.Router()
        var binding = Set<AnyCancellable>()
        
        deinit {
            vm.comic.detail = nil
        }
        
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
            
            if vm.comic.detail == nil {
                vm.doAction(.loadData)
            }
            else {
                vo.reloadUI(comic: vm.comic)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension Detail.VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reuseCell(UITableViewCell.self, for: indexPath)
        let episode = vm.episodes[indexPath.row]
        cell.textLabel?.text = episode.title
        cell.accessoryType = episode.watched ? .checkmark : .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension Detail.VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = vm.episodes[indexPath.row]
        vm.doAction(.saveHistory(episode: episode))
        router.toReader(comic: vm.comic)
    }
}

// MARK: - Setup Something

private extension Detail.VC {
    func setupSelf() {
        title = "詳細"
        router.vc = self
        navigationItem.rightBarButtonItem = makeRightItem()
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
            case .tapFavorite:
                self?.stateTapFavorite()
            }
        }.store(in: &binding)
    }
    
    func setupVO() {
        vo.list.delegate = self
        vo.list.dataSource = self
        vo.list.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
}

// MARK: - Handle State

private extension Detail.VC {
    func stateNone() {}
    
    func stateShowLoading() {
        let alert = UIAlertController(title: "更新中...", message: nil, preferredStyle: .alert)
        
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
        vo.reloadUI(comic: vm.comic)
    }
    
    func stateTapFavorite() {
        navigationItem.rightBarButtonItem = makeRightItem()
    }
}

// MARK: - Make Something

private extension Detail.VC {
    func makeRightItem() -> UIBarButtonItem {
        switch vm.comic.isFavorite {
        case true:
            return .init(image: .init(systemName: "star.fill"), style: .plain, target: self, action: #selector(tapFavorite))
        case false:
            return .init(image: .init(systemName: "star"), style: .plain, target: self, action: #selector(tapFavorite))
        }
    }
}

// MARK: - Target / Action

private extension Detail.VC {
    @objc func reloadData() {
        vo.list.refreshControl?.endRefreshing()
        vm.doAction(.loadData)
    }
    
    @objc func tapFavorite() {
        vm.doAction(.tapFavorite)
    }
}
