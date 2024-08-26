//
//  FilterManager.swift
//

import Foundation
import Combine

class FilterManager<T>: ObservableObject {
    @Published var searchText: String = ""
    @Published var filters: [String: Set<String>] = [:]
    @Published var sortOption: String
    @Published var sortOrder: SortOrder = .ascending
    
    let sortKeyPath: (String) -> ((T, T) -> Bool)
    
    init(initialSortOption: String, sortKeyPath: @escaping (String) -> ((T, T) -> Bool)) {
        self.sortOption = initialSortOption
        self.sortKeyPath = sortKeyPath
    }
    
    var isEmpty: Bool {
        filters.isEmpty && searchText.isEmpty
    }
    
    var count: Int {
        filters.values.reduce(0) { $0 + $1.count }
    }
    
    func addFilter(_ value: String, forKey key: String) {
        filters[key, default: []].insert(value)
    }
    
    func removeFilter(_ value: String, forKey key: String) {
        filters[key]?.remove(value)
        if filters[key]?.isEmpty == true {
            filters.removeValue(forKey: key)
        }
    }
    
    func filter(_ items: [T], using predicate: (T, [String: Set<String>], String) -> Bool) -> [T] {
        items.filter { predicate($0, filters, searchText) }
            .sorted(by: sortedComparator)
    }
    
    private var sortedComparator: (T, T) -> Bool {
        let comparator = sortKeyPath(sortOption)
        return sortOrder == .ascending ? comparator : { !comparator($0, $1) }
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .ascending ? .descending : .ascending
    }
}
