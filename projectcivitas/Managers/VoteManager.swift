import Foundation

class VotingManager: ObservableObject {
    @Published private(set) var bills: [Bill] = []
    private let dataSource: DataAccessLayer
    private let userVotingRecord: UserVotingRecord
    
    init(dataSource: DataAccessLayer, userVotingRecord: UserVotingRecord) {
        self.dataSource = dataSource
        self.userVotingRecord = userVotingRecord
        
        Task {
            await fetchBills()
        }
    }
    
    @MainActor
    func fetchBills() async {
        do {
            bills = try await dataSource.fetchBills()
        } catch {
            print("Error fetching bills: \(error)")
        }
    }
    
    func vote(for bill: Bill, vote: Vote) {
        Task {
            await updateVote(for: bill, vote: vote)
        }
    }
    
    @MainActor
    private func updateVote(for bill: Bill, vote: Vote) async {
        guard let index = bills.firstIndex(where: { $0.id == bill.id }) else { return }
        
        var updatedBill = bills[index]
        
        if let previousVote = updatedBill.userVote {
            if previousVote == .yes {
                updatedBill.yesVotes -= 1
            } else if previousVote == .no {
                updatedBill.noVotes -= 1
            }
        }
        
        updatedBill.userVote = vote
        
        if vote == .yes {
            updatedBill.yesVotes += 1
        } else if vote == .no {
            updatedBill.noVotes += 1
        }
        
        bills[index] = updatedBill
        userVotingRecord.recordVote(billId: bill.id, vote: vote)
        
        do {
            try await dataSource.updateBill(updatedBill)
        } catch {
            print("Error updating bill: \(error)")
            // You might want to implement some error handling or rollback logic here
        }
    }
}

class UserVotingRecord: ObservableObject {
    @Published var votes: [UUID: Vote] = [:]
    
    func recordVote(billId: UUID, vote: Vote) {
        votes[billId] = vote
    }
}
