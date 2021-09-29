//
//  BasePage.swift
//  DTMvvm
//
//  Created by ToanDK on 8/13/19.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import PureLayout

open class BasePage: UIViewController, ITransitionView {
    
    public var disposeBag: DisposeBag? = DisposeBag()
    
    public var animatorDelegate: AnimatorDelegate?
    
    public private(set) var backButton: UIBarButtonItem?
    
    private lazy var backAction: Action<Void, Void> = {
        return Action() { .just(self.onBack()) }
    }()
    
    public var enableBackButton: Bool = false {
        didSet {
            if enableBackButton {
                backButton = backButtonFactory().create()
                navigationItem.leftBarButtonItem = backButton
                backButton?.rx.bind(to: backAction, input: ())
            } else {
                navigationItem.leftBarButtonItem = nil
                backButton?.rx.unbindAction()
            }
        }
    }
    
    public let navigationService: INavigationService = DependencyManager.shared.getService()
    
    deinit {
        destroy()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        initialize()
        updateAfterViewModelChanged()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            destroy()
        }
    }
    
    /**
     Subclasses override this method to create its own back button on navigation bar.
     
     This method allows subclasses to create custom back button. To create the default back button, use global configurations `DDConfigurations.backButtonFactory`
     */
    open func backButtonFactory() -> Factory<UIBarButtonItem> {
        return DDConfigurations.backButtonFactory
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
        cleanUp()
    }
    
    /**
     Subclasses override this method to create custom back action for back button.
     
     By default, this will call pop action in navigation or dismiss in modal
     */
    open func onBack() {
        navigationService.pop()
    }
    
    /**
     Subclasses override this method to do more action when `viewModel` changed.
     */
    open func viewModelChanged() { }
    
    private func cleanUp() {
        disposeBag = nil
    }
    
    func updateAfterViewModelChanged() {
        bindViewAndViewModel()
        
        viewModelChanged()
    }
}
