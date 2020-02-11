//
//  ListPage.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 9/26/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

open class ListPage<VM: IListViewModel>: Page<VM> {
    public var tableView: UITableView?
    
    public typealias CVM = VM.CellViewModelElement
    
    public var dataSource: RxTableViewSectionedAnimatedDataSource<SectionList<CVM>>?
    var didBindViewModel = false
    
    override open func viewDidLoad() {
        if tableView == nil {
            tableView = UITableView(frame: view.bounds, style: .plain)
        }
        tableView?.backgroundColor = .clear
        view.addSubview(tableView!)
        
        super.viewDidLoad()
        if !didBindViewModel {
            bindViewAndViewModel()
        }
    }
    
    open override func initialize() {
        tableView?.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open override func destroy() {
        super.destroy()
        tableView?.removeFromSuperview()
        tableView = nil
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
