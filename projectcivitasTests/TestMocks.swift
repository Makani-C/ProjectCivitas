//
//  TestMocks.swift
//  projectcivitasTests
//
//  Created by Makani Cartwright on 8/29/24.
//

import Foundation
@testable import projectcivitas


class TestDataSource: DataSourceProtocol {
    private var bills: [Bill]
    private var legislators: [Legislator]
    private var legislatorVotes: [LegislatorVote]
    private var userVotes: [UserVote]
    private var comments: [UUID: [Comment]] = [:]
    
    init() {
        let bill = Bill(id: UUID(), title: "Test Bill", description: "Test Description", state: "Test State", body: "Test Body", session: "Test Session", tags: ["Test"], briefing: "Test Briefing", lastUpdated: Date(), yesVotes: 0, noVotes: 0)
        let legislator = Legislator(id: UUID(), name: "Test Legislator", party: "Test Party", state: "Test State", district: "Test District", chamber: "Test Chamber", imageUrl: "Test URL", topIssues: ["Test Issue"], contactInfo: ContactInfo(email: "test@test.com", phone: "1234567890", office: "Test Office"), socialMedia: SocialMedia(twitter: "test", facebook: "test", instagram: "test"), fundingRecord: [])
        let legislatorVote = LegislatorVote(id: UUID(), billId: bill.id, legislatorId: legislator.id, vote: .yes, date: Date())
        
        self.bills = [bill]
        self.legislators = [legislator]
        self.legislatorVotes = [legislatorVote]
        self.userVotes = []
    }
    
    func fetchBills() async throws -> [Bill] { return bills }
    
    func fetchLegislators() async throws -> [Legislator] { return legislators }
    
    func updateBill(_ bill: Bill) async throws {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index] = bill
        } else {
            throw DataManagerError.billNotFound
        }
    }
    
    func updateLegislator(_ legislator: Legislator) async throws {
        if let index = legislators.firstIndex(where: { $0.id == legislator.id }) {
            legislators[index] = legislator
        } else {
            throw DataManagerError.legislatorNotFound
        }
    }
    
    func addComment(_ comment: Comment, to billId: UUID) async throws {
        if comments[billId] != nil {
            comments[billId]?.append(comment)
        } else {
            comments[billId] = [comment]
        }
    }
    
    func fetchComments(for billId: UUID) async throws -> [Comment] {
        return comments[billId] ?? []
    }
    
    func fetchLegislatorVotingRecord() async throws -> [LegislatorVote] {
        return legislatorVotes
    }
    
    func fetchUserVotingRecord() async throws -> [UserVote] {
        return userVotes
    }
    
    func updateUserVotingRecord(_ userVote: UserVote) async throws {
        if let index = userVotes.firstIndex(where: { $0.id == userVote.id }) {
            userVotes[index] = userVote
        }
    }

    func fetchCompleteBillText(billId: UUID) async throws -> String {
        return "Complete text for bill \(billId)"
    }
}
