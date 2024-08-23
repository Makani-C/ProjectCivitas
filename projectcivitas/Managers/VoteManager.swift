//
//  VoteManager.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation

class VotingManager: ObservableObject {
    @Published var bills: [Bill]
    @Published var userVotingRecord: UserVotingRecord
    
    init(bills: [Bill], userVotingRecord: UserVotingRecord = UserVotingRecord()) {
        self.bills = bills
        self.userVotingRecord = userVotingRecord
    }
    
    func vote(for bill: Bill, vote: Vote) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            if bills[index].userVote == vote {
                // Retract vote
                bills[index].userVote = nil
                userVotingRecord.votes.removeValue(forKey: bill.id)
                if vote == .yes {
                    bills[index].yesVotes -= 1
                } else {
                    bills[index].noVotes -= 1
                }
            } else {
                // Change vote or add new vote
                if let previousVote = bills[index].userVote {
                    if previousVote == .yes {
                        bills[index].yesVotes -= 1
                    } else {
                        bills[index].noVotes -= 1
                    }
                }
                bills[index].userVote = vote
                userVotingRecord.recordVote(for: bill.id, vote: vote)
                if vote == .yes {
                    bills[index].yesVotes += 1
                } else {
                    bills[index].noVotes += 1
                }
            }
        }
    }
}

class UserVotingRecord: ObservableObject {
    @Published var votes: [UUID: Vote] = [:]
    
    func recordVote(for billId: UUID, vote: Vote) {
        votes[billId] = vote
    }
}
