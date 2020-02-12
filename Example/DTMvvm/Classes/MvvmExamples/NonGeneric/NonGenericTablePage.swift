//
//  NonGenericTablePage.swift
//  DTMvvm_Example
//
//  Created by ToanDK on 8/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import DTMvvm
import RxCocoa
import RxSwift
import Action

class NonGenericTablePage: BaseListPage {
    var viewModel: NonGenericTableViewModel? {
        return _viewModel as? NonGenericTableViewModel
    }
    
    @IBOutlet weak var _tableView: UITableView! {
        didSet {
            self.tableView = _tableView
        }
    }
    
    @IBAction func addAction() {
        viewModel?.add()
    }
    
    override func initialize() {
        tableView?.estimatedRowHeight = 100
        tableView?.register(UINib(nibName: "NGListPageCell", bundle: nil), forCellReuseIdentifier: NGListPageCell.identifier)
    }
    
    override func cellIdentifier(_ cellViewModel: Any) -> String {
        return NGListPageCell.identifier
    }
    
    override func selectedItemDidChange(_ cellViewModel: Any) {
        print("select \(cellViewModel)")
    }
}

class NonGenericTableViewModel: ListViewModel<Model, SimpleListPageCellViewModel> {
    
    lazy var addAction: Action<Void, Void> = {
        return Action() { .just(self.add()) }
    }()
    
    func add() {
        let number = Int.random(in: 1000...10000)
        let title = "This is your random number: \(number)"
        let cvm = SimpleListPageCellViewModel(model: SimpleModel(withTitle: title))
        itemsSource.append(cvm)
    }
}
