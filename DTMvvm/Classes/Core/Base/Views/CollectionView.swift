//
//  CollectionView.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 10/28/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

open class CollectionView<VM: IListViewModel>: View<VM> {
    
    public typealias CVM = VM.CellViewModelElement
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    var didBindViewModel = false
    
    public var dataSource: RxCollectionViewSectionedAnimatedDataSource<SectionList<CVM>>?
    
    override func setup() {
        addSubview(collectionView)
        super.setup()
    }
    
    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    open override func initialize() {
        collectionView.autoPinEdgesToSuperviewEdges()
    }
    
    open override func destroy() {
        super.destroy()
        collectionView.removeFromSuperview()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        didBindViewModel = true
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionList<CVM>>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cellViewModel = item
                let identifier = self.cellIdentifier(cellViewModel)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
                if let cell = cell as? IAnyView {
                    cell.anyViewModel = cellViewModel
                }
                (cellViewModel as? IIndexable)?.indexPath = indexPath
                return cell
        })
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: collectionView.rx.items(dataSource: dataSource!)) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        selectedItemDidChange(cellViewModel)
    }
    
    // MARK: - Abstract for subclasses
    
    /**
     Subclasses have to override this method to return correct cell identifier based `CVM` type.
     */
    open func cellIdentifier(_ cellViewModel: CVM) -> String {
        fatalError("Subclasses have to implemented this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
}
