import SwiftUI

protocol DataAccessLayer {
    func fetchBills() async throws -> [Bill]
    func fetchLegislators() async throws -> [Legislator]
    func updateBill(_ bill: Bill) async throws
    func updateLegislator(_ legislator: Legislator) async throws
    func addComment(to billId: UUID, comment: Comment) async throws
    func fetchComments(for billId: UUID) async throws -> [Comment]
}

class MockDataSource: DataAccessLayer {
    private var bills: [Bill]
    private var legislators: [Legislator]
    
    init() {
        // Initialize with sample data
        self.bills = sampleBills
        self.legislators = sampleLegislators
    }
    
    func fetchBills() async throws -> [Bill] {
        return bills
    }
    
    func fetchLegislators() async throws -> [Legislator] {
        return legislators
    }
    
    func updateBill(_ bill: Bill) async throws {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index] = bill
        }
    }
    
    func updateLegislator(_ legislator: Legislator) async throws {
        if let index = legislators.firstIndex(where: { $0.id == legislator.id }) {
            legislators[index] = legislator
        }
    }
    
    func addComment(to billId: UUID, comment: Comment) async throws {
        if let index = bills.firstIndex(where: { $0.id == billId }) {
            bills[index].comments.append(comment)
        }
    }
    
    func fetchComments(for billId: UUID) async throws -> [Comment] {
        if let bill = bills.first(where: { $0.id == billId }) {
            return bill.comments
        }
        return []
    }
}
