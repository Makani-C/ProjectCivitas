import SwiftUI

protocol DataAccessLayer {
    func fetchBills() async throws -> [Bill]
    func fetchLegislators() async throws -> [Legislator]
    func updateBill(_ bill: Bill) async throws
    func updateLegislator(_ legislator: Legislator) async throws
    func addComment(to billId: UUID, comment: Comment) async throws
    func fetchComments(for billId: UUID) async throws -> [Comment]
    func fetchAllVotingRecords() async throws -> [VotingRecord]
    func fetchVotingRecordsForLegislator(legislatorId: UUID) async throws -> [VotingRecord]
    func fetchVotingRecordsForBill(billId: UUID) async throws -> [VotingRecord]
    func fetchCompleteBillText(billId: UUID) async throws -> Text
}

class DataManager: ObservableObject {
    private let dataSource: DataAccessLayer
    @Published var bills: [Bill] = []
    @Published var legislators: [Legislator] = []
    @Published var votingRecords: [VotingRecord] = []

    init(dataSource: DataAccessLayer) {
        self.dataSource = dataSource
        Task {
            await loadData()
        }
    }

    @MainActor
    func loadData() async {
        do {
            bills = try await dataSource.fetchBills()
            legislators = try await dataSource.fetchLegislators()
            votingRecords = try await dataSource.fetchAllVotingRecords()
        } catch {
            print("Error loading data: \(error)")
        }
    }

    func fetchComments(for billId: UUID) async throws -> [Comment] {
        return try await dataSource.fetchComments(for: billId)
    }

    func addComment(to billId: UUID, comment: Comment) async throws {
        try await dataSource.addComment(to: billId, comment: comment)
    }
}
