//
//  FeedManager.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/23/24.
//
//
//import Foundation
//
//class FeedDataManager: ObservableObject {
//    @Published var feedItems: [FeedItem] = []
//    @Published var selectedTags: Set<String> = []
//    
//    private var bills: [UUID: Bill] = [:]
//    private var legislators: [UUID: Legislator] = [:]
//    private var allTags: Set<String> = []
//    
//    func loadData() {
//        // Simulate loading data from a database or API
//        // In a real app, this would be an asynchronous operation
//        
//        // Load bills
//        let sampleBills = [
//            Bill(id: UUID(), title: "EPA Bill", description: "Environmental Protection Act", tags: ["environment", "regulation"]),
//            Bill(id: UUID(), title: "WWC Bill", description: "Clean Water Act", tags: ["environment", "water"])
//        ]
//        sampleBills.forEach { bills[$0.id] = $0 }
//        
//        // Load legislators
//        let sampleLegislators = [
//            Legislator(id: UUID(), name: "John Smith", party: "Democratic", state: "California", tags: ["environment", "healthcare"]),
//            Legislator(id: UUID(), name: "Jane Doe", party: "Republican", state: "Texas", tags: ["economy", "defense"])
//        ]
//        sampleLegislators.forEach { legislators[$0.id] = $0 }
//        
//        // Create feed items
//        feedItems = [
//            FeedItem(
//                id: UUID(),
//                title: "New Environmental Bills",
//                description: "Multiple bills on environmental protection have been introduced.",
//                date: Date(),
//                associatedItems: sampleBills.map { AssociatedItem(id: UUID(), type: .bill, itemId: $0.id) },
//                tags: ["environment", "legislation"]
//            ),
//            FeedItem(
//                id: UUID(),
//                title: "Legislators Update Voting Records",
//                description: "Several legislators have updated their voting records.",
//                date: Date(),
//                associatedItems: sampleLegislators.map { AssociatedItem(id: UUID(), type: .legislator, itemId: $0.id) },
//                tags: ["voting", "update"]
//            )
//        ]
//        
//        // Collect all unique tags
//        allTags = Set(feedItems.flatMap { $0.tags } + sampleBills.flatMap { $0.tags } + sampleLegislators.flatMap { $0.tags })
//    }
//    
//    func getAssociatedItemDetails(_ item: AssociatedItem) -> (title: String, tags: [String]) {
//        switch item.type {
//        case .bill:
//            if let bill = bills[item.itemId] {
//                return (bill.title, bill.tags)
//            }
//        case .legislator:
//            if let legislator = legislators[item.itemId] {
//                return (legislator.name, legislator.tags)
//            }
//        }
//        return ("Unknown", [])
//    }
//    
//    func filterFeedItems() -> [FeedItem] {
//        guard !selectedTags.isEmpty else { return feedItems }
//        
//        return feedItems.filter { item in
//            let itemTags = Set(item.tags)
//            let associatedTags = Set(item.associatedItems.flatMap { getAssociatedItemDetails($0).tags })
//            return !selectedTags.isDisjoint(with: itemTags.union(associatedTags))
//        }
//    }
//}
