//
// VoteManager.swift
//

import Foundation

enum VotingError: Error {
    case billNotFound
    case updateFailed(Error)
    
    var localizedDescription: String {
       switch self {
       case .billNotFound:
           return "The bill was not found in the current list of bills."
       case .updateFailed(let error):
           return "Failed to update the bill: \(error.localizedDescription)"
       }
   }
}

class VoteManager: ObservableObject {
    @Published private(set) var bills: [Bill] = []
    
    private let dataManager: DataManager
    private let userVotingRecord: UserVotingRecord
    
    init(dataManager: DataManager, userVotingRecord: UserVotingRecord) {
        self.dataManager = dataManager
        self.userVotingRecord = userVotingRecord
        
        Task {
            await syncBills()
        }
    }
    
    @MainActor
    private func syncBills() {
        self.bills = dataManager.bills.map { bill in
            var updatedBill = bill
            updatedBill.userVote = userVotingRecord.getVote(for: bill.id)
            return updatedBill
        }
    }
    
    @MainActor
   func vote(for bill: Bill, vote: Vote) async throws {
       syncBills()
       
       guard let index = bills.firstIndex(where: { $0.id == bill.id }) else {
           throw VotingError.billNotFound
       }
       
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
       
       do {
           try await dataManager.updateBill(updatedBill)
           bills[index] = updatedBill
           userVotingRecord.recordVote(billId: bill.id, vote: vote)
           syncBills()
           self.objectWillChange.send()
       } catch {
           print("Failed to update bill: \(error.localizedDescription)")
           throw VotingError.updateFailed(error)
       }
   }
}



class UserVotingRecord: ObservableObject {
    @Published var votes: [UUID: Vote] = [:]
    
    @MainActor
    func recordVote(billId: UUID, vote: Vote) {
        votes[billId] = vote
        self.objectWillChange.send()
    }
    
    func getVote(for billId: UUID) -> Vote? {
        return votes[billId]
    }
}
