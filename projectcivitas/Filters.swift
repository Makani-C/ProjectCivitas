//
//  Filters.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation

struct LegislatorFilters {
    var parties: Set<String> = []
    var states: Set<String> = []
    var chambers: Set<String> = []
    
    var isEmpty: Bool {
        parties.isEmpty && states.isEmpty && chambers.isEmpty
    }
    
    var count: Int {
        parties.count + states.count + chambers.count
    }
}
