//
//  VoteManagerTests.swift
//

import XCTest
@testable import projectcivitas

class VoteManagerTests: XCTestCase {
    var testVoteManager: VoteManager!
    var testDataManager: DataManager!
    var testDataSource: TestDataSource!
    let testUserId = UUID()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        testDataSource = TestDataSource()
        testDataManager = DataManager(dataSource: testDataSource)
        testVoteManager = VoteManager(userId: testUserId, dataManager: testDataManager)
        
        let expectation = self.expectation(description: "Data loaded")
        Task {
            await testDataManager.loadData()
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    override func tearDownWithError() throws {
        testDataSource = nil
        testDataManager = nil
        testVoteManager = nil
        try super.tearDownWithError()
    }
    
    func testCastVote() async throws {
        // Given
        await testDataManager.loadData()
        let bill = testDataManager.bills[0]
        let vote = Vote.yes
        
        // When
        _ = try await testVoteManager.castVote(for: bill, vote: vote)
        
        // Then
        let result = testVoteManager.getUserVotingRecord(for: testUserId)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.billId, bill.id)
    }
    
    func testGetLegislatorVotes() {
        // Given
        let bill = testDataManager.bills[0]
        let legislator = testDataManager.legislators[0]
        
        // When
        let result = testVoteManager.getLegislatorVotes(for: bill.id)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.legislatorId, legislator.id)
    }
    
    func testGetLegislatorVotingRecord() {
        // Given
        let legislator = testDataManager.legislators[0]
        
        // When
        let result = testVoteManager.getLegislatorVotingRecord(for: legislator.id)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.legislatorId, legislator.id)
    }
    
    func testGetUserLegislatorAlignmentScore() async throws {
        // Given
        let bill = testDataManager.bills[0]
        let legislator = testDataManager.legislators[0]
        
        // Then
        var score = testVoteManager.getUserLegislatorAlignmentScore(legislatorId: legislator.id, userId: testUserId)
        XCTAssertNil(score, "Alignment score should be nil when no votes have been cast")
        
        // Given a matching vote
        _ = try await testVoteManager.castVote(for: bill, vote: .yes)
        
        // Then
        score = testVoteManager.getUserLegislatorAlignmentScore(legislatorId: legislator.id, userId: testUserId)
        XCTAssertNotNil(score, "Alignment score should not be nil after casting a vote")
        if let actualScore = score {
            XCTAssertEqual(actualScore, 100.0, accuracy: 0.01, "Score should be 100% for matching votes")
        }
        
        // Given a non-matching vote
        _ = try await testVoteManager.castVote(for: bill, vote: .no)
        
        // Then
        score = testVoteManager.getUserLegislatorAlignmentScore(legislatorId: legislator.id, userId: testUserId)
        XCTAssertNotNil(score, "Alignment score should not be nil after casting a vote")
        if let actualScore = score {
            XCTAssertEqual(actualScore, 0.0, accuracy: 0.01, "Score should be 0% for one non-matching vote")
        }
    }
    
    func testGetLegislatorAttendanceScore() {
        // Given
        let legislator = testDataManager.legislators[0]
        
        // When
        let score = testVoteManager.getLegislatorAttendanceScore(for: legislator.id)
        
        // Then
        XCTAssertNotNil(score, "Attendance score should not be null if the legislator has voted")
        if let actualScore = score {
            XCTAssertEqual(actualScore, 100.0, accuracy: 0.01, "Score should be 100% for one present vote")
        }
    }
}
