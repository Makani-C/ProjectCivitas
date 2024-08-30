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
    private let userId: UUID
    private let dataManager: DataManager
    
    init(userId: UUID, dataManager: DataManager) {
        self.userId = userId
        self.dataManager = dataManager
    }
    
    @MainActor
    func castVote(for bill: Bill, vote: Vote) async throws -> Bill {
        do {
            try await dataManager.updateUserVotingRecord(billId: bill.id, userId: self.userId, vote: vote)
        } catch {
            print("Failed to update vote: \(error.localizedDescription)")
            throw VotingError.updateFailed(error)
        }
        
        var updatedBill = bill
        if let previousVote = bill.userVote {
            if previousVote == .yes {
                updatedBill.yesVotes -= 1
            } else {
                updatedBill.noVotes -= 1
            }
        }
        if vote == .yes {
            updatedBill.yesVotes += 1
        } else {
            updatedBill.noVotes += 1
        }
        updatedBill.userVote = vote
        try await dataManager.updateBill(updatedBill)
        self.objectWillChange.send()

        return updatedBill
    }
    
    func getUserVotes(for billId: UUID) -> [UserVote] {
        return dataManager.userVotes.filter { $0.billId == billId }
    }
    
    func getLegislatorVotes(for billId: UUID) -> [LegislatorVote] {
        return dataManager.legislatorVotes.filter { $0.billId == billId }
    }
    
    func getLegislatorVotingRecord(for legislatorId: UUID) -> [LegislatorVote] {
        return dataManager.legislatorVotes.filter { $0.legislatorId == legislatorId }
    }
    
    func getUserVotingRecord(for userId: UUID) -> [UserVote] {
        return dataManager.userVotes.filter { $0.userId == userId }
    }
    
    func getUserLegislatorAlignmentScore(legislatorId: UUID, userId: UUID) -> Double? {
        let legislatorVotes = getLegislatorVotingRecord(for: legislatorId)
        let userVotes = getUserVotingRecord(for: userId)
        
        let legislatorVotesDict = Dictionary(uniqueKeysWithValues: legislatorVotes.map { ($0.billId, $0.vote) })
    
        var totalVotesOnSameBills = 0
        var matchingVoteCount = 0
        for userVote in userVotes {
            if let legislatorVote = legislatorVotesDict[userVote.billId] {
                totalVotesOnSameBills += 1
                if userVote.vote == legislatorVote {
                    matchingVoteCount += 1
                }
            }
        }
        guard totalVotesOnSameBills > 0 else { return nil }
        
        return Double(matchingVoteCount) / Double(totalVotesOnSameBills) * 100
    }
    
    func getLegislatorAttendanceScore(for legislatorId: UUID) -> Double? {
        let legislatorVotes = getLegislatorVotingRecord(for: legislatorId)

        var totalVotes = 0
        var attendedVotes = 0
        for vote in legislatorVotes where vote.legislatorId == legislatorId {
            totalVotes += 1
            if vote.vote != .notPresent {
                attendedVotes += 1
            }
        }
        
        guard totalVotes > 0 else { return nil }
        return Double(attendedVotes) / Double(totalVotes) * 100
    }
}
