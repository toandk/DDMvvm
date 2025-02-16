//
//  ListView.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 10/28/18.
//

import UIKit

open class ListView<VM: IListViewModel>: View<VM>, UITableViewDataSource, UITableViewDelegate {

    public typealias CVM = VM.CellViewModelElement
    
    public let tableView: UITableView
    
    public init(viewModel: VM? = nil, style: UITableView.Style = .plain) {
        tableView = UITableView(frame: .zero, style: style)
        super.init(viewModel: viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        addSubview(tableView)
        
        super.setup()
    }
    
    open override func initialize() {
        tableView.autoPinEdgesToSuperviewEdges(with: .zero)
    }
    
    open override func destroy() {
        super.destroy()
        tableView.removeFromSuperview()
    }
    
    /// Every time the viewModel changed, this method will be called again, so make sure to call super for ListPage to work
    open override func bindViewAndViewModel() {
        tableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.onItemSelected(indexPath)
            }) => disposeBag
        viewModel?.itemsSource.collectionChanged
            .subscribe(onNext: { [weak self] changeSet in
                self?.onDataSourceChanged(changeSet)
            }) => disposeBag
    }
    
    private func onItemSelected(_ indexPath: IndexPath) {
        guard let viewModel = viewModel,
            indexPath.section < viewModel.itemsSource.count,
            indexPath.row < viewModel.itemsSource[indexPath.section].count
            else { return }
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        viewModel.rxSelectedItem.accept(cellViewModel)
        viewModel.rxSelectedIndex.accept(indexPath)
        
        viewModel.selectedItemDidChange(cellViewModel)
        
        selectedItemDidChange(cellViewModel)
    }
    
    private func onDataSourceChanged(_ changeSet: ChangeSet) {
        if changeSet.animated {
            switch changeSet {
            case let data as ModifySection:
                switch data.type {
                case .insert:
                    tableView.insertSections([data.section], with: .top)
                    
                case .delete:
                    if data.section < 0 {
                        if tableView.numberOfSections > 0 {
                            let sections = IndexSet(0...tableView.numberOfSections - 1)
                            tableView.deleteSections(sections, with: .bottom)
                        } else {
                            tableView.reloadData()
                        }
                    } else {
                        tableView.deleteSections([data.section], with: .bottom)
                    }
                    
                default:
                    if data.section < 0 {
                        if tableView.numberOfSections > 0 {
                            let sections = IndexSet(0...tableView.numberOfSections - 1)
                            tableView.reloadSections(sections, with: .automatic)
                        } else {
                            tableView.reloadData()
                        }
                    } else {
                        tableView.reloadSections(IndexSet([data.section]), with: .automatic)
                    }
                }
            case let data as ModifyElements:
                switch data.type {
                case .insert:
                    tableView.insertRows(at: data.indexPaths, with: .top)
                    
                case .delete:
                    tableView.deleteRows(at: data.indexPaths, with: .bottom)
                    
                default:
                    tableView.reloadRows(at: data.indexPaths, with: .automatic)
                }
                
            case let data as MoveElements:
                tableView.beginUpdates()
                
                for (i, fromIndexPath) in data.fromIndexPaths.enumerated() {
                    let toIndexPath = data.toIndexPaths[i]
                    tableView.moveRow(at: fromIndexPath, to: toIndexPath)
                }
                
                tableView.endUpdates()
                
            default:
                tableView.reloadData()
            }
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Abstract for subclasses
    
    open func cellIdentifier(_ cellViewModel: CVM) -> String {
        fatalError("Subclasses have to implement this method.")
    }
    
    open func selectedItemDidChange(_ cellViewModel: CVM) { }
    
    // MARK: - Table view datasources
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.itemsSource.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.itemsSource.countElements(at: section) ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
            indexPath.section < viewModel.itemsSource.count,
            indexPath.row < viewModel.itemsSource[indexPath.section].count
            else {
            return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        let cellViewModel = viewModel.itemsSource[indexPath.row, indexPath.section]
        
        // set index for each cell
        (cellViewModel as? IIndexable)?.indexPath = indexPath
        
        let identifier = cellIdentifier(cellViewModel)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? IAnyView {
            cell.anyViewModel = cellViewModel
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Table view delegates
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}
