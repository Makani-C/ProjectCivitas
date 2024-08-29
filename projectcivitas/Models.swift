//
//  Models.swift
//

import Foundation

protocol Followable: Identifiable {
    var id: UUID { get }
}

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}


enum Vote: String {
    case yes, no, abstain, notPresent
}

struct Bill: Identifiable, Followable {
    let id: UUID
    let title: String
    let description: String
    let state: String
    let body: String
    let session: String
    let tags: [String]
    let briefing: String
    let lastUpdated: Date
    
    var yesVotes: Int
    var noVotes: Int
    var userVote: Vote?
    
    func getVotingRecord(allVotingRecords: [VotingRecord]) -> [VotingRecord] {
        return allVotingRecords.filter { $0.billId == self.id }
    }
}

struct Legislator: Identifiable, Followable {
    let id: UUID
    let name: String
    let party: String
    let state: String
    let district: String?
    let chamber: String
    let imageUrl: String
    let topIssues: [String]
    let contactInfo: ContactInfo
    let socialMedia: SocialMedia
    let fundingRecord: [FundingRecord]
    
    func getVotingRecord(allVotingRecords: [VotingRecord]) -> [VotingRecord] {
        return allVotingRecords.filter { $0.legislatorId == self.id }
    }
    
    func alignmentScore(with userVotes: [UUID: Vote], votingRecords: [VotingRecord]) -> Double? {
        var totalVotes = 0
        var matchingVotes = 0
        
        for record in votingRecords where record.legislatorId == self.id {
            totalVotes += 1
            if let userVote = userVotes[record.billId], record.vote == userVote {
                matchingVotes += 1
            }
        }
        
        guard totalVotes > 0 else { return nil }
        return Double(matchingVotes) / Double(totalVotes) * 100
    }
    
    func attendanceScore(votingRecords: [VotingRecord]) -> Double? {
        var totalVotes = 0
        var attendedVotes = 0
        
        for record in votingRecords where record.legislatorId == self.id {
            totalVotes += 1
            if record.vote != .notPresent {
                attendedVotes += 1
            }
        }
        
        guard totalVotes > 0 else { return nil }
        return Double(attendedVotes) / Double(totalVotes) * 100
    }
}

struct ContactInfo {
    let email: String
    let phone: String
    let office: String
}

struct SocialMedia {
    let twitter: String?
    let facebook: String?
    let instagram: String?
}

struct VotingRecord: Identifiable {
    let id: UUID
    let billId: UUID
    let legislatorId: UUID
    let vote: Vote
    let date: Date
}

struct FundingRecord: Identifiable {
    let id = UUID()
    let source: String
    let amount: Double
    let date: Date
}
