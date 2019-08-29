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
    var viewModel: NonGenericTableViewModel!
    @IBOutlet weak var addButton: UIButton!
    
    override func setupTableView(_ tableView: UITableView) {
        super.setupTableView(tableView)
        tableView.estimatedRowHeight = 100
        tableView.register(SimpleListPageCell.self, forCellReuseIdentifier: SimpleListPageCell.identifier)
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard let viewModel = viewModel else { return }
        addButton.rx.bind(to: viewModel.addAction, input: ())
    }
    
    override func destroy() {
        super.destroy()
        viewModel.destroy()
    }
    
    override func cellIdentifier(_ cellViewModel: Any) -> String {
        return SimpleListPageCell.identifier
    }
    
    override func getItemSource() -> RxCollection? {
        return self.viewModel!.itemsSource
    }
}

class NonGenericTableViewModel: ListViewModel<Model, SimpleListPageCellViewModel> {
    
    lazy var addAction: Action<Void, Void> = {
        return Action() { .just(self.add()) }
    }()
    
    private func add() {
        let number = Int.random(in: 1000...10000)
        let title = "This is your random number: \(number)"
        let cvm = SimpleListPageCellViewModel(model: SimpleModel(withTitle: title))
        itemsSource.append(cvm)
    }
}
