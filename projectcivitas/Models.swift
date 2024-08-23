//
//  Models.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation


struct Bill: Identifiable {
    let id = UUID()
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
    
    enum Vote {
        case yes, no
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
    let billTitle: String
    let vote: String
    let date: Date
}
