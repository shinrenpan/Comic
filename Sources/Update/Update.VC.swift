//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension Update {
    final class VC: UIViewController {
        var vo = Update.VO()
        var vm = Update.VM()
        var router = Update.Router()
        var binding = Set<AnyCancellable>()
        
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
            
            if vm.comics.isEmpty {
                vm.doAction(.loadData)
            }
            else {
                vm.doAction(.checkFavorite)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension Update.VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.comics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reuseCell(Update.Views.Cell.self, for: indexPath)
        let comic = vm.comics[indexPath.row]
        cell.reloadUI(comic: comic)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension Update.VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comic = vm.comics[indexPath.row]
        router.toDetail(comic: comic)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let comic = vm.comics[indexPath.row]
        let actions = makeSwipeAction(comic: comic)
        return .init(actions: actions)
    }
}

// MARK: - Setup Something

private extension Update.VC {
    func setupSelf() {
        title = "更新列表"
        router.vc = self
        navigationItem.rightBarButtonItem = makeReloadItem()
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
            case .addFavorite:
                self?.stateAddFavorite()
            case .removeFavorite:
                self?.stateRemoveFavorite()
            }
        }.store(in: &binding)
    }
    
    func setupVO() {
        vo.list.delegate = self
        vo.list.dataSource = self
    }
}

// MARK: - Handle State

private extension Update.VC {
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
        vo.reloadList(isEmpty: vm.comics.isEmpty)
    }
    
    func stateAddFavorite() {
        vo.reloadList(isEmpty: vm.comics.isEmpty)
    }
    
    func stateRemoveFavorite() {
        vo.reloadList(isEmpty: vm.comics.isEmpty)
    }
}

// MARK: - Make Something

private extension Update.VC {
    func makeSwipeAction(comic: Comic.Models.DisplayComic) -> [UIContextualAction] {
        let isFavorite = comic.isFavorite
        let title = isFavorite ? "取消收藏" : "收藏"
        
        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            switch isFavorite {
            case true:
                self?.vm.doAction(.removeFavorite(comic: comic))
            case false:
                self?.vm.doAction(.addFavorite(comic: comic))
            }
        }
        
        action.backgroundColor = isFavorite ? .red : .blue
        
        return [action]
    }
    
    func makeReloadItem() -> UIBarButtonItem {
        .init(title: "更新", style: .done, target: self, action: #selector(tapReload))
    }
}

// MARK: - Target / Action

private extension Update.VC {
    @objc func tapReload() {
        vm.doAction(.loadData)
    }
}
