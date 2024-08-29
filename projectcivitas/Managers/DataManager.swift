//
//  DataManager.swift
//

import SwiftUI


enum DataManagerError: Error {
    case billNotFound
    case legislatorNotFound
    case updateFailed(Error)
}

protocol DataManagerProtocol {
    var bills: [Bill] { get }
    var legislators: [Legislator] { get }
    var votingRecords: [VotingRecord] { get }
    
    func loadData() async
    func fetchComments(for billId: UUID) async throws -> [Comment]
}

protocol DataSourceProtocol {
    func fetchBills() async throws -> [Bill]
    func updateBill(_ bill: Bill) async throws
    
    func fetchLegislators() async throws -> [Legislator]
    
    func fetchVotingRecords() async throws -> [VotingRecord]
    
    func fetchComments(for billId: UUID) async throws -> [Comment]
    func addComment(_ comment: Comment, to billId: UUID) async throws
}


class DataManager: ObservableObject {
    @Published private(set) var bills: [Bill] = []
    @Published private(set) var legislators: [Legislator] = []
    @Published private(set) var votingRecords: [VotingRecord] = []
    @Published private(set) var isLoading = false

    private let dataSource: DataSourceProtocol
    
    init(dataSource: DataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        do {
            async let billsFetch = dataSource.fetchBills()
            async let legislatorsFetch = dataSource.fetchLegislators()
            async let votingRecordsFetch = dataSource.fetchVotingRecords()
            
            let (fetchedBills, fetchedLegislators, fetchedVotingRecords) = try await (billsFetch, legislatorsFetch, votingRecordsFetch)
            
            bills = fetchedBills
            legislators = fetchedLegislators
            votingRecords = fetchedVotingRecords
        } catch {
            // Handle error (e.g., show an alert, log the error)
            print("Error loading data: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func updateBill(_ updatedBill: Bill) async throws {
        guard let index = bills.firstIndex(where: { $0.id == updatedBill.id }) else {
            throw DataManagerError.billNotFound
        }
        
        do {
            try await dataSource.updateBill(updatedBill)
            bills[index] = updatedBill
        } catch {
            throw DataManagerError.updateFailed(error)
        }
    }
    
    func getComments(for billId: UUID) async throws -> [Comment] {
        try await dataSource.fetchComments(for: billId)
    }
    
    func addComment(to billId: UUID, comment: Comment) async throws {
        print(1)
        try await dataSource.addComment(comment, to: billId)
        print(2)
    }
    
    func getVotingRecords(for billId: UUID) async throws -> [VotingRecord] {
        return self.votingRecords.filter { $0.billId == billId }
    }
}
