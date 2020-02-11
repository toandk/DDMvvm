//
//  Protocols.swift
//
//  Created by toandk on 12/25/19.
//  Copyright © 2019 toandk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

/// Destroyable type for handling dispose bag and destroy it
public protocol IDestroyable: class {
    
    var disposeBag: DisposeBag? { get set }
    func destroy()
}

public protocol IAnyView: class {
    
    /**
     Any value assign to this property will be delegate to its correct viewModel type
     */
    var anyViewModel: Any? { get set }
}

/// Base View type for the whole library
public protocol IView: IAnyView, IDestroyable {
    
    associatedtype ViewModelElement
    
    var viewModel: ViewModelElement? { get set }
    
    func initialize()
    func bindViewAndViewModel()
}

/// PopView type for Page to implement as a pop view
public protocol IPopupView: class {
    
    /*
     Setup popup layout
     
     Popview is a UIViewController base, therefore it already has a filled view in. This method allows
     implementation to layout it customly. For example:
     
     ```
     view.cornerRadius = 7
     view.autoCenterInSuperview()
     ```
     */
    func popupLayout()
    
    /*
     Show animation
     
     The presenter page has overlayView, use this if we want to animation the overlayView too, e.g alpha
     */
    func show(overlayView: UIView)
    
    /*
     Hide animation
     
     Must call completion when the animation is finished
     */
    func hide(overlayView: UIView, completion: @escaping (() -> ()))
}

/// TransitionView type to create custom transitioning between pages
public protocol ITransitionView: class {
    
    /**
     Keep track of animator delegate for custom transitioning
     */
    var animatorDelegate: AnimatorDelegate? { get set }
}

public protocol IdentifyEquatable: Equatable, IdentifiableType {
    
}



public protocol IModelType: IDestroyable {
    func getModel() -> Any?
}

public protocol IEquatableModelType: IModelType, IdentifyEquatable {
    
}

public extension IEquatableModelType {
    var identity: String {
        return String(describing: self.getModel())
    }
}

/// Base generic viewModel type, implement Destroyable and Equatable
public protocol IViewModel: IEquatableModelType where Identity == String {
    
    associatedtype ModelElement
    
    var model: ModelElement? { get set }
    
    init(model: ModelElement?)
}

public extension IViewModel {
    func getModel() -> Any? {
        return model
    }
}

public protocol IListItemType {
    var rxNSObjectSources: BehaviorRelay<[SectionList<NSObject>]> { get }
    func getItem(at indexPath: IndexPath) -> Any?
}

public protocol IListViewModel: IViewModel, IListItemType {
    
    associatedtype CellViewModelElement: IViewModel
    
    var itemsSource: ReactiveCollection<CellViewModelElement> { get }
    var rxSelectedItem: BehaviorRelay<CellViewModelElement?> { get }
    var rxSelectedIndex: BehaviorRelay<IndexPath?> { get }
    
    func selectedItemDidChange(_ cellViewModel: CellViewModelElement)
    
}

public extension IListViewModel {
    var rxNSObjectSources: BehaviorRelay<[SectionList<NSObject>]> {
        return itemsSource.rxNSObjectSources
    }
    
    func getItem(at indexPath: IndexPath) -> Any? {
        return itemsSource[indexPath.section][indexPath.row]
    }
}

extension NSObject: IdentifyEquatable {
    public typealias Identity = String
    public var identity: String {
        return "\(self)"
    }
}
