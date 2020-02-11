//
//  BaseView.swift
//  Test2
//
//  Created by toandk on 12/26/19.
//  Copyright © 2019 toandk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PureLayout

open class BaseView: UIView {
    
    public var disposeBag: DisposeBag? = DisposeBag()
    public var _viewModel: IModelType?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open func setup() {
        
        initialize()
        DispatchQueue.main.async {
            self.viewModelChanged()
        }
    }
    
    /**
     Subclasses override this method to initialize UIs.
     
     This method is called in `viewDidLoad`. So try not to use `viewModel` property if you are
     not sure about it
     */
    open func initialize() {}
    
    /**
     Subclasses override this method to create data binding between view and viewModel.
     
     This method always happens, so subclasses should check if viewModel is nil or not. For example:
     ```
     guard let viewModel = viewModel else { return }
     ```
     */
    open func bindViewAndViewModel() {}
    
    /**
     Subclasses override this method to remove all things related to `DisposeBag`.
     */
    open func destroy() {
        disposeBag = DisposeBag()
        _viewModel?.destroy()
    }
    
    private func viewModelChanged() {
        bindViewAndViewModel()
        (_viewModel as? IReactable)?.reactIfNeeded()
    }
}
