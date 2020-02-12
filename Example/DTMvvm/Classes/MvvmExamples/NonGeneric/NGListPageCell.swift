//
//  NGListPageCell.swift
//  DTMvvm_Example
//
//  Created by toandk on 2/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

class NGListPageCell: TableCell<SimpleListPageCellViewModel> {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.rxTitle ~> titleLbl.rx.text => disposeBag
    }
}
