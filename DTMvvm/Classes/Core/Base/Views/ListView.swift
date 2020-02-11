//
//  ListView.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 10/28/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

open class ListView<VM: IListViewModel>: View<VM> {
    
    public typealias CVM = VM.CellViewModelElement
    
    public var tableView: UITableView?
    
    public var dataSource: RxTableViewSectionedAnimatedDataSource<SectionList<CVM>>?
    var didBindViewModel = false
    
    override func setup() {
        if tableView == nil {
            tableView = UITableView(frame: bounds, style: .plain)
        }
        tableView?.backgroundColor = .clear
        if nil == tableView?.superview {
            addSubview(tableView!)
        }
        
        super.setup()
    }
    
    open override func initialize() {
        tableView?.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open override func destroy() {
        super.destroy()
        tableView?.removeFromSuperview()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        guard let tableView = tableView else { return }
        didBindViewModel = true
        tableView.rx.itemSelected.asObservable().subscribe(onNext: onItemSelected) => disposeBag
        
        dataSource = RxTableViewSectionedAnimatedDataSource<SectionList<CVM>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cellViewModel = item
                let identifier = self.cellIdentifier(cellViewModel)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                if let cell = cell as? IAnyView {
                    cell.anyViewModel = cellViewModel
                }
                (cellViewModel as? IIndexable)?.indexPath = indexPath
                return cell
        })
        
        viewModel?.itemsSource.rxInnerSources
            .bind(to: tableView.rx.items(dataSource: dataSource!)) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = self.viewModel else { return }
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
        fatalError("Subclasses have to implement this method.")
    }
    
    /**
     Subclasses override this method to handle cell pressed action.
     */
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
}
