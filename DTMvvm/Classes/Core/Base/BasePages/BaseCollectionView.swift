//
//  BaseCollectionView.swift
//  Test2
//
//  Created by toandk on 2/7/20.
//  Copyright © 2020 toandk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

open class BaseCollectionView: BaseView {
    
    public var collectionView: UICollectionView!
    public var dataSource: RxCollectionViewSectionedAnimatedDataSource<SectionList<NSObject>>?
    
    override open func setup() {
        if collectionView == nil {
            collectionView = UICollectionView(frame: .zero)
            addSubview(collectionView)
            DispatchQueue.main.async {
                self.bindViewAndViewModel()
            }
        }
        collectionView.backgroundColor = .clear
        super.setup()
    }
    
    open override func initialize() {
        collectionView.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open override func destroy() {
        super.destroy()
        collectionView.removeFromSuperview()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard collectionView != nil else { return }
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionList<NSObject>>(
            configureCell: { dataSource, tableView, indexPath, item in
                if let cellViewModel = item as? IModelType {
                    let identifier = self.cellIdentifier(cellViewModel)
                    let cell = tableView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
                    if let cell = cell as? IAnyView {
                        cell.anyViewModel = cellViewModel
                    }
                    (cellViewModel as? IIndexable)?.indexPath = indexPath
                    return cell
                }
                return UICollectionViewCell()
        })
        
        (_viewModel as? IListItemType)?.rxNSObjectSources
            .bind(to: collectionView.rx.items(dataSource: dataSource!)) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = self._viewModel as? IListItemType,
            let cellViewModel = viewModel.getItem(at: indexPath)
            else { return }
        
        selectedItemDidChange(cellViewModel)
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: Any) -> String {
        fatalError("Subclasses have to implement this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: Any) { }
}
