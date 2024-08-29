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
   func vote(for bill: Bill, vote: Vote) async throws {
       do {
           // TODO - fetch instead if it already exists
           let newVotingRecord = UserVote(id: UUID(), billId: bill.id, userId: self.userId, vote: vote, date: Date())
           try await dataManager.updateUserVotingRecord(newVotingRecord)
           self.objectWillChange.send()
       } catch {
           print("Failed to update bill: \(error.localizedDescription)")
           throw VotingError.updateFailed(error)
       }
   }
    
    func getUserBillVotingRecord(billId: UUID) -> [UserVote] {
        return dataManager.userVotes.filter { $0.billId == billId }
    }
    
    func getLegislatorBillVotingRecord(billId: UUID) -> [LegislatorVote] {
        return dataManager.legislatorVotes.filter { $0.billId == billId }
    }
    
    func getLegislatorVotingRecord(legislatorId: UUID) -> [LegislatorVote] {
        return dataManager.legislatorVotes.filter { $0.legislatorId == legislatorId }
    }
    
    func getUserVotingRecord(userId: UUID) -> [UserVote] {
        return dataManager.userVotes.filter { $0.userId == userId }
    }
    
    func getUserLegislatorAlignmentScore(legislatorId: UUID, userId: UUID) -> Double? {
        let legislatorVotes = getLegislatorVotingRecord(legislatorId: legislatorId)
        let userVotes = getUserVotingRecord(userId: userId)
        
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
        let legislatorVotes = getLegislatorVotingRecord(legislatorId: legislatorId)

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
