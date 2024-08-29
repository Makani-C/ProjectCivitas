//
//  DataManager.swift
//

import SwiftUI


enum DataManagerError: Error {
    case billNotFound
    case legislatorNotFound
    case updateFailed(Error)
}

protocol DataSourceProtocol {
    func fetchBills() async throws -> [Bill]
    func updateBill(_ bill: Bill) async throws
    
    func fetchLegislators() async throws -> [Legislator]
    
    func fetchLegislatorVotingRecord() async throws -> [LegislatorVote]
    func fetchUserVotingRecord() async throws -> [UserVote]
    
    func updateUserVotingRecord(_ votingRecord: UserVote) async throws
    
    func fetchComments(for billId: UUID) async throws -> [Comment]
    func addComment(_ comment: Comment, to billId: UUID) async throws
}


class DataManager: ObservableObject {
    @Published private(set) var bills: [Bill] = []
    @Published private(set) var isLoading = false
    @Published private(set) var legislators: [Legislator] = []
    @Published private(set) var legislatorVotes: [LegislatorVote] = []
    @Published private(set) var userVotes: [UserVote] = []

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
            async let legislatorVotingRecordsFetch = dataSource.fetchLegislatorVotingRecord()
            async let userVotingRecordsFetch = dataSource.fetchUserVotingRecord()
            
            let (fetchedBills, fetchedLegislators, fetchedLegislatorVotingRecords, fetchedUserVotingRecords) = try await (billsFetch, legislatorsFetch, legislatorVotingRecordsFetch, userVotingRecordsFetch)
            
            bills = fetchedBills
            legislators = fetchedLegislators
            legislatorVotes = fetchedLegislatorVotingRecords
            userVotes = fetchedUserVotingRecords
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
    
    func getBill(for billId: UUID) async throws -> Bill {
        guard let index = bills.firstIndex(where: { $0.id == billId }) else {
            throw DataManagerError.billNotFound
        }
        return bills[index]
    }
    
    func getComments(for billId: UUID) async throws -> [Comment] {
        try await dataSource.fetchComments(for: billId)
    }
    
    func addComment(to billId: UUID, comment: Comment) async throws {
        try await dataSource.addComment(comment, to: billId)
    }
    
    func updateUserVotingRecord(_ userVotingRecord: UserVote) async throws {
        try await dataSource.updateUserVotingRecord(userVotingRecord)
    }
    
    func getUserVotingRecords(for billId: UUID) async throws -> [UserVote] {
        return self.userVotes.filter { $0.billId == billId }
    }
    
    func getLegislatorVotingRecords(for billId: UUID) async throws -> [LegislatorVote] {
        return self.legislatorVotes.filter { $0.billId == billId }
    }
}
