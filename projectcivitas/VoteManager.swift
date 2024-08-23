//
//  VoteManager.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation


class VotingManager: ObservableObject {
    @Published var bills: [Bill]
    
    init(bills: [Bill]) {
        self.bills = bills
    }
    
    func vote(for bill: Bill, vote: Bill.Vote) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            if bills[index].userVote == vote {
                // Retract vote
                bills[index].userVote = nil
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
                if vote == .yes {
                    bills[index].yesVotes += 1
                } else {
                    bills[index].noVotes += 1
                }
            }
        }
    }
}
