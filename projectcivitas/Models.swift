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

struct LegislatorVote: Identifiable {
    let id: UUID
    let billId: UUID
    let legislatorId: UUID
    let vote: Vote
    let date: Date
}

struct UserVote: Identifiable {
    let id: UUID
    let billId: UUID
    let userId: UUID
    let vote: Vote
    let date: Date
}

struct FundingRecord: Identifiable {
    let id = UUID()
    let source: String
    let amount: Double
    let date: Date
}
