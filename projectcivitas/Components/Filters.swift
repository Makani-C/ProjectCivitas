//
//  Filters.swift
//

import Foundation
import Combine

struct Filters {
    var tags: Set<String> = []
    var sessions: Set<String> = []
    var bodies: Set<String> = []
    
    var isEmpty: Bool {
        tags.isEmpty && sessions.isEmpty && bodies.isEmpty
    }
    
    var count: Int {
        tags.count + sessions.count + bodies.count
    }
}

enum SortOrder {
    case ascending, descending
}

struct FilterCategory<T> {
    let name: String
    let key: String
    let values: [String]
}

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
        filters.values.allSatisfy { $0.isEmpty }
    }
    
    var count: Int {
        filters.values.reduce(0) { $0 + $1.count }
    }
    
    func addFilter(_ value: String, forKey key: String) {
        if filters[key] == nil {
            filters[key] = Set<String>()
        }
        filters[key]?.insert(value)
    }
    
    func removeFilter(_ value: String, forKey key: String) {
        filters[key]?.remove(value)
        if filters[key]?.isEmpty == true {
            filters.removeValue(forKey: key)
        }
    }
    
    func filter(_ items: [T], using predicate: (T, [String: Set<String>], String) -> Bool) -> [T] {
        let filteredItems = items.filter { item in
            predicate(item, filters, searchText)
        }
        return filteredItems.sorted(by: sortedComparator)
    }
    
    private var sortedComparator: (T, T) -> Bool {
        let comparator = sortKeyPath(sortOption)
        return sortOrder == .ascending ? comparator : { !comparator($0, $1) }
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .ascending ? .descending : .ascending
    }
}
