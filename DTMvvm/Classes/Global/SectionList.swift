//
//  SectionList.swift
//  DTMvvm
//
//  Created by Dao Duy Duong on 9/26/18.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public protocol RxCollection {
    var count: Int { get }
    func removeAll(animated: Bool?)
    func element(atIndexPath: IndexPath) -> Any?
    func element(atSection: Int, row: Int) -> Any?
    func countElements(at section: Int) -> Int
}

/// Section list data sources
public class SectionList<T>: AnimatableSectionModelType where T: IdentifyEquatable {
    public typealias Identity = String
    
    public let key: Any
    
    public var identity: String {
        return "\(key)"
    }
    
    public var items = [T]()
    
    public required init(original: SectionList<T>, items: [T]) {
        self.key = original.key
        self.items = items
    }
    
    public subscript(index: Int) -> T {
        get { return items[index] }
        set(newValue) { insert(newValue, at: index) }
    }
    
    public var count: Int {
        return items.count
    }
    
    public var first: T? {
        return items.first
    }
    
    public var last: T? {
        return items.last
    }
    
    public var allElements: [T] {
        return items
    }
    
    public init(_ key: Any, initialElements: [T] = []) {
        self.key = key
        items.append(contentsOf: initialElements)
    }
    
    public func forEach(_ body: ((Int, T) -> ())) {
        for (i, element) in items.enumerated() {
            body(i, element)
        }
    }
    
    fileprivate func insert(_ element: T, at index: Int) {
        items.insert(element, at: index)
    }
    
    fileprivate func insert(_ elements: [T], at index: Int) {
        items.insert(contentsOf: elements, at: index)
    }
    
    fileprivate func append(_ element: T) {
        items.append(element)
    }
    
    fileprivate func append(_ elements: [T]) {
        items.append(contentsOf: elements)
    }
    
    @discardableResult
    fileprivate func remove(at index: Int) -> T? {
        return items.remove(at: index)
    }
    
    fileprivate func remove(at indice: [Int]) {
        let newSources = items.enumerated().compactMap { indice.contains($0.offset) ? nil : $0.element }
        items = newSources
    }
    
    fileprivate func removeAll() {
        items.removeAll()
    }
    
    fileprivate func sort(by predicate: (T, T) throws -> Bool) rethrows {
        try items.sort(by: predicate)
    }
    
    @discardableResult
    fileprivate func firstIndex(of element: T) -> Int? {
        return items.firstIndex(of: element)
    }
    
    @discardableResult
    fileprivate func lastIndex(of element: T) -> Int? {
        return items.lastIndex(of: element)
    }
    
    @discardableResult
    fileprivate func firstIndex(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try items.firstIndex(where: predicate)
    }
    
    @discardableResult
    fileprivate func lastIndex(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try items.lastIndex(where: predicate)
    }
    
    fileprivate func map<U>(_ transform: (T) throws -> U) rethrows -> [U] {
        return try items.map(transform)
    }
    
    fileprivate func compactMap<U>(_ transform: (T) throws -> U?) rethrows -> [U] {
        return try items.compactMap(transform)
    }
    
    func toNSObjectList() -> SectionList<NSObject> {
        let newList: SectionList<NSObject> = SectionList<NSObject>("a")
        for item in items {
            if let item = item as? NSObject {
                newList.append(item)
            }
        }
        return newList
    }
}

public class ReactiveCollection<T>: RxCollection, SectionModelType where T: IdentifyEquatable {
    public typealias Item = SectionList<T>
    public var items: [Item] = []
    
    private func getNSItems() -> [SectionList<NSObject>] {
        var nsItems: [SectionList<NSObject>] = []
        for item in items {
            nsItems.append(item.toNSObjectList())
        }
        return nsItems
    }
    
    public init() {
        
    }
    
    public required init(original: ReactiveCollection<T>, items: [SectionList<T>]) {
        self.items = items
    }
    
    public func element(atIndexPath: IndexPath) -> Any? {
        return self[atIndexPath.row, atIndexPath.section]
    }
    
    public func element(atSection: Int, row: Int) -> Any? {
        return self[row, atSection]
    }
    
    public var animated: Bool = true
    
    public let rxInnerSources = BehaviorRelay<[SectionList<T>]>(value: [])
    public let rxNSObjectSources = BehaviorRelay<[SectionList<NSObject>]>(value: [])
    
    public subscript(index: Int, section: Int) -> T {
        get { return items[section][index] }
        set(newValue) { insert(newValue, at: index, of: section) }
    }
    
    public subscript(index: Int) -> SectionList<T> {
        get { return items[index] }
        set(newValue) { insertSection(newValue, at: index) }
    }
    
    public var count: Int {
        return items.count
    }
    
    public var first: SectionList<T>? {
        return items.first
    }
    
    public var last: SectionList<T>? {
        return items.last
    }
    
    public func forEach(_ body: ((Int, SectionList<T>) -> ())) {
        for (i, section) in items.enumerated() {
            body(i, section)
        }
    }
    
    public func countElements(at section: Int = 0) -> Int {
        guard section >= 0 && section < items.count else { return 0 }
        return items[section].count
    }
    
    // MARK: - section manipulations
    
    public func reload(at section: Int = -1, animated: Bool? = nil) {
        if items.count > 0 && section < items.count {
            rxInnerSources.accept(items)
            rxNSObjectSources.accept(getNSItems())
        }
    }
    
    public func reset(_ elements: [T], of section: Int = 0, animated: Bool? = nil) {
        if section < items.count {
            items[section].removeAll()
            items[section].append(elements)
            
            rxInnerSources.accept(items)
            rxNSObjectSources.accept(getNSItems())
        }
    }
    
    public func reset(_ sources: [[T]], animated: Bool? = nil) {
        reset(sources.map { SectionList("", initialElements: $0) }, animated: animated)
    }
    
    public func reset(_ sources: [SectionList<T>], animated: Bool? = nil) {
        items.removeAll()
        items.append(contentsOf: sources)
        
        reload(animated: animated)
    }
    
    public func insertSection(_ key: String, elements: [T], at index: Int, animated: Bool? = nil) {
        insertSection(SectionList<T>(key, initialElements: elements), at: index, animated: animated)
    }
    
    public func insertSection(_ sectionList: SectionList<T>, at index: Int, animated: Bool? = nil) {
        if items.count == 0 {
            items.append(sectionList)
        } else {
            items.insert(sectionList, at: index)
        }
        
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
    }
    
    public func appendSections(_ sectionLists: [SectionList<T>], animated: Bool? = nil) {
        for sectionList in sectionLists {
            appendSection(sectionList, animated: animated)
        }
    }
    
    public func appendSection(_ key: String, elements: [T], animated: Bool? = nil) {
        appendSection(SectionList<T>(key, initialElements: elements), animated: animated)
    }
    
    public func appendSection(_ sectionList: SectionList<T>, animated: Bool? = nil) {
        items.append(sectionList)
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
    }
    
    @discardableResult
    public func removeSection(at index: Int, animated: Bool? = nil) -> SectionList<T> {
        let element = items.remove(at: index)
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
        
        return element
    }
    
    public func removeAll(animated: Bool? = nil) {
        items.removeAll()
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
    }
    
    // MARK: - section elements manipulations
    
    public func insert(_ element: T, at indexPath: IndexPath, animated: Bool? = nil) {
        insert(element, at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    public func insert(_ element: T, at index: Int, of section: Int = 0, animated: Bool? = nil) {
        insert([element], at: index, of: section, animated: animated)
    }
    
    public func insert(_ elements: [T], at indexPath: IndexPath, animated: Bool? = nil) {
        insert(elements, at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    public func insert(_ elements: [T], at index: Int, of section: Int = 0, animated: Bool? = nil) {
        if section >= items.count {
            appendSection("", elements: elements, animated: animated)
            return
        }
        
        if items[section].count == 0 {
            items[section].append(elements)
        } else if index < items[section].count {
            items[section].insert(elements, at: index)
        }
        
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
    }
    
    public func append(_ element: T, to section: Int = 0, animated: Bool? = nil) {
        append([element], to: section, animated: animated)
    }
    
    public func append(_ elements: [T], to section: Int = 0, animated: Bool? = nil) {
        if section >= items.count {
            appendSection("", elements: elements, animated: animated)
            return
        }
        
        items[section].append(elements)
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
    }
    
    @discardableResult
    public func remove(at indexPath: IndexPath, animated: Bool? = nil) -> T? {
        return remove(at: indexPath.row, of: indexPath.section, animated: animated)
    }
    
    @discardableResult
    public func remove(at index: Int, of section: Int = 0, animated: Bool? = nil) -> T? {
        if let element = items[section].remove(at: index) {
            rxInnerSources.accept(items)
            rxNSObjectSources.accept(getNSItems())
            
            return element
        }
        
        return nil
    }
    
    @discardableResult
    public func remove(at indice: [Int], of section: Int = 0, animated: Bool? = nil) -> [T] {
        return remove(at: indice.map { IndexPath(row: $0, section: section) })
    }
    
    @discardableResult
    public func remove(at indexPaths: [IndexPath], animated: Bool? = nil) -> [T] {
        let removedElements = indexPaths.compactMap { items[$0.section].remove(at: $0.row) }
        
        rxInnerSources.accept(items)
        rxNSObjectSources.accept(getNSItems())
        
        return removedElements
    }
    
    public func sort(by predicate: (T, T) throws -> Bool, at section: Int = 0, animated: Bool? = nil) rethrows {
        let oldElements = items[section].allElements
        
        try items[section].sort(by: predicate)
        
        let newElements = items[section].allElements
        
        var fromIndexPaths: [IndexPath] = []
        var toIndexPaths: [IndexPath] = []
        oldElements.enumerated().forEach { (i, element) in
            if let newIndex = newElements.firstIndex(of: element) {
                toIndexPaths.append(IndexPath(row: newIndex, section: section))
                fromIndexPaths.append(IndexPath(row: i, section: section))
            }
        }
        
        if fromIndexPaths.count == toIndexPaths.count {
            rxInnerSources.accept(items)
            rxNSObjectSources.accept(getNSItems())
        }
    }
    
    
    public func asObservable() -> Observable<[SectionList<T>]> {
        return rxInnerSources.asObservable()
    }
    
    public func indexForSection(withKey key: AnyObject) -> Int? {
        return items.firstIndex(where: { key.isEqual($0.key) })
    }
    
    @discardableResult
    public func firstIndex(of element: T, at section: Int = 0) -> Int? {
        return items[section].firstIndex(of: element)
    }
    
    @discardableResult
    public func lastIndex(of element: T, at section: Int) -> Int? {
        return items[section].lastIndex(of: element)
    }
    
    @discardableResult
    public func firstIndex(where predicate: (T) throws -> Bool, at section: Int) rethrows -> Int? {
        return try items[section].firstIndex(where: predicate)
    }
    
    @discardableResult
    public func lastIndex(where predicate: (T) throws -> Bool, at section: Int) rethrows -> Int? {
        return try items[0].lastIndex(where: predicate)
    }
}
