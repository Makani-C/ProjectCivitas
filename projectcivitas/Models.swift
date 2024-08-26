//
//  Models.swift
//

import Foundation

protocol Followable: Identifiable {
    var id: UUID { get }
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
    var yesVotes: Int
    var noVotes: Int
    var userVote: Vote?
    var comments: [Comment]
    let lastUpdated: Date
    
    var totalCommentCount: Int {
        comments.reduce(0) { $0 + $1.totalReplyCount + 1 }
    }
}

struct Legislator: Identifiable, Followable {
    let id = UUID()
    let name: String
    let party: String
    let state: String
    let district: String?
    let chamber: String
    let imageUrl: String
    let topIssues: [String]
    let contactInfo: ContactInfo
    let socialMedia: SocialMedia
    let votingRecord: [VotingRecord]
    let fundingRecord: [FundingRecord]
    
    func alignmentScore(with userVotes: [UUID: Vote]) -> Double? {
        let totalVotes = votingRecord.count
        guard totalVotes > 0 else { return nil }
        let matchingVotes = votingRecord.filter { record in
            guard let userVote = userVotes[record.billId] else {
                return false
            }
            return record.vote == userVote
        }
        return Double(matchingVotes.count) / Double(totalVotes) * 100
    }
    
    func attendanceScore() -> Double? {
        let totalVotes = votingRecord.count
        guard totalVotes > 0 else { return nil }
        
        let attendedVotes = votingRecord.filter { $0.vote != .notPresent }.count
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
    let id = UUID()
    let billId: UUID
    let vote: Vote
    let date: Date
}

struct FundingRecord: Identifiable {
    let id = UUID()
    let source: String
    let amount: Double
    let date: Date
}
