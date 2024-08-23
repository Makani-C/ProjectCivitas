//
//  Models.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation

enum Vote: String {
    case yes, no
}

struct Bill: Identifiable {
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
    var lastUpdated: Date
    
    init(id: UUID = UUID(), title: String, description: String, state: String, body: String, session: String, tags: [String], briefing: String, yesVotes: Int, noVotes: Int, userVote: Vote?, comments: [Comment], lastUpdated: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.state = state
        self.body = body
        self.session = session
        self.tags = tags
        self.briefing = briefing
        self.yesVotes = yesVotes
        self.noVotes = noVotes
        self.userVote = userVote
        self.comments = comments
        self.lastUpdated = lastUpdated
    }
}

struct Comment: Identifiable {
    let id = UUID()
    let user: String
    let text: String
    let timestamp: Date
    var replies: [Comment] = []
    let parentId: UUID? // nil for top-level comments
}

struct Filters {
    var tags: Set<String> = []
    var sessions: Set<String> = []
    var bodies: Set<String> = []
    
    var isEmpty: Bool {
        tags.isEmpty && sessions.isEmpty && bodies.isEmpty
    }
    
    var count: Int {
        tags.count + sessions.count + bodies.count
    }
}

struct Legislator: Identifiable {
    let id = UUID()
    let name: String
    let party: String
    let state: String
    let district: String?
    let chamber: String
    let imageUrl: String
    let biography: String
    let topIssues: [String]
    let contactInfo: ContactInfo
    let socialMedia: SocialMedia
    let votingRecord: [VotingRecord]
    
    func alignmentScore(with userVotes: [UUID: Vote]) -> Double {
        let matchingVotes = votingRecord.filter { record in
            guard let userVote = userVotes[record.billId] else {
                return false
            }
            return record.vote == userVote
        }
        
        return Double(matchingVotes.count) / Double(votingRecord.count) * 100
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
