//
//  Filters.swift
//

import Foundation
import Combine

struct Filters {
    var followed: Bool = false
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
