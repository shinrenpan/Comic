//
// Copyright (c) 2023 Shinren Pan
//

import Combine
import UIKit

extension History {
    final class VC: UIViewController {
        var vo = History.VO()
        var vm = History.VM()
        var router = History.Router()
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
            vm.doAction(.loadData)
        }
    }
}

// MARK: - UITableViewDataSource

extension History.VC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.comics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reuseCell(History.Views.Cell.self, for: indexPath)
        let comic = vm.comics[indexPath.row]
        cell.reloadUI(comic: comic)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension History.VC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comic = vm.comics[indexPath.row]
        router.toDetail(comic: comic)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let comic = vm.comics[indexPath.row]
        let actions = makeSwipeAction(comic: comic)
        return .init(actions: actions)
    }
}

// MARK: - TabScrollableVC

extension History.VC: TabScrollableVC {
    var scrollView: UIScrollView {
        return vo.list
    }
}

// MARK: - Setup Something

private extension History.VC {
    func setupSelf() {
        title = "觀看紀錄"
        router.vc = self
    }
    
    func setupBinding() {
        vm.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            if self?.viewIfLoaded?.window == nil { return }
            
            switch state {
            case .none:
                self?.stateNone()
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

private extension History.VC {
    func stateNone() {}
    
    func stateLoadedData() {
        vo.reloadList(isEmpty: vm.comics.isEmpty)
        navigationItem.rightBarButtonItem = makeRemoveAllItem()
    }
}

// MARK: - Make Something

private extension History.VC {
    func makeSwipeAction(comic: Comic.Models.DisplayComic) -> [UIContextualAction] {
        let action = UIContextualAction(style: .destructive, title: "移除") { [weak self] _, _, _ in
            self?.vm.doAction(.removeHistory(comic: comic))
        }
        
        return [action]
    }
    
    func makeRemoveAllItem() -> UIBarButtonItem? {
        switch vm.comics.isEmpty {
        case true:
            return nil
        case false:
            return .init(title: "移除全部", style: .done, target: self, action: #selector(tapRemoveAll))
        }
    }
}

// MARK: - Target / Action

private extension History.VC {
    @objc func tapRemoveAll() {
        let alert = UIAlertController(title: "移除全部", message: "確定移除全部紀錄?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "確定", style: .destructive) { [weak self] _ in
            self?.vm.doAction(.removeAll)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: false)
    }
}
