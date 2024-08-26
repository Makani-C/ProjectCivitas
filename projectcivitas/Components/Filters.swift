//
//  Filters.swift

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

class FilterManager<T: Followable>: ObservableObject {
    @Published var searchText: String = "" {
        didSet { updateFilteredItems() }
    }
    @Published var filters: [String: Set<String>] = [:] {
        didSet { updateFilteredItems() }
    }
    @Published var sortOption: String {
        didSet { updateFilteredItems() }
    }
    @Published var sortOrder: SortOrder = .ascending {
        didSet { updateFilteredItems() }
    }
    @Published var showOnlyFollowed = false {
        didSet { updateFilteredItems() }
    }
    @Published private(set) var filteredItems: [T] = []
    
    private var allItems: [T] = []
    let sortKeyPath: (String) -> ((T, T) -> Bool)
    private let settingsManager: SettingsManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(initialSortOption: String, sortKeyPath: @escaping (String) -> ((T, T) -> Bool), settingsManager: SettingsManager) {
        self.sortOption = initialSortOption
        self.sortKeyPath = sortKeyPath
        self.settingsManager = settingsManager
        
        settingsManager.objectWillChange
            .sink { [weak self] _ in
                print("FilterManager: SettingsManager changed, updating filtered items")
                self?.updateFilteredItems()
            }
            .store(in: &cancellables)
    }
    
    func setItems(_ items: [T]) {
        self.allItems = items
        updateFilteredItems()
    }
    
    private func updateFilteredItems() {
        filteredItems = filter(allItems) { item, filters, searchText in
            let matchesFilters = filters.isEmpty || filters.allSatisfy { key, values in
                switch key {
                case "tags": return !Set((item as? Bill)?.tags ?? []).isDisjoint(with: values)
                case "sessions": return values.contains((item as? Bill)?.session ?? "")
                case "bodies": return values.contains((item as? Bill)?.body ?? "")
                case "parties": return values.contains((item as? Legislator)?.party ?? "")
                case "states": return values.contains((item as? Legislator)?.state ?? "")
                case "chambers": return values.contains((item as? Legislator)?.chamber ?? "")
                default: return true
                }
            }
            let matchesSearch = searchText.isEmpty || ((item as? Bill)?.title.lowercased().contains(searchText.lowercased()) ?? false) || ((item as? Legislator)?.name.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesFollowed = !showOnlyFollowed || settingsManager.isFollowing(item)
            return matchesFilters && matchesSearch && matchesFollowed
        }
        
        let comparator = sortKeyPath(sortOption)
        filteredItems.sort(by: sortOrder == .ascending ? comparator : { !comparator($0, $1) })
        
        objectWillChange.send()
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
            let matchesFilters = predicate(item, filters, searchText)
            let matchesFollowed = !showOnlyFollowed || settingsManager.isFollowing(item)
            print("FilterManager: Filtering item \(item.id), matchesFilters: \(matchesFilters), matchesFollowed: \(matchesFollowed), showOnlyFollowed: \(showOnlyFollowed)")
            return matchesFilters && matchesFollowed
        }
        print("FilterManager: Filtered \(items.count) items down to \(filteredItems.count) items")
        return filteredItems
    }
    
    private func refilter() {
        objectWillChange.send()
    }
    
    private var sortedComparator: (T, T) -> Bool {
        let comparator = sortKeyPath(sortOption)
        return sortOrder == .ascending ? comparator : { !comparator($0, $1) }
    }
    
    func toggleSortOrder() {
        sortOrder = sortOrder == .ascending ? .descending : .ascending
    }
}
