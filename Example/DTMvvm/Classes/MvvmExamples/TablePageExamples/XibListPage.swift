//
//  XibListPage.swift
//  DTMvvm_Example
//
//  Created by apolo2 on 7/21/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm

class XibListPage: ListPage<SimpleListPageViewModel> {

    let contentView: XibListPageContentView = XibListPageContentView.loadFrom(nibNamed: "XibListPageContentView")!
    
    override func addTableView() {
        view.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
    }
    
    override var tableView: UITableView {
        return contentView.tableView
    }
    
    override func initialize() {
        super.initialize()
        enableBackButton = true
        
        tableView.estimatedRowHeight = 100
        tableView.register(SimpleListPageCell.self, forCellReuseIdentifier: SimpleListPageCell.identifier)
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        
        guard let viewModel = viewModel else { return }
        
        contentView.addButton.rx.bind(to: viewModel.addAction, input: ())
    }
    
    override func cellIdentifier(_ cellViewModel: SimpleListPageCellViewModel) -> String {
        return SimpleListPageCell.identifier
    }
    
}
