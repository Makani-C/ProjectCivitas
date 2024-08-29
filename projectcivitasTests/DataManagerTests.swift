//
//  DataManagerTests.swift
//

import XCTest
@testable import projectcivitas

class DataManagerTests: XCTestCase {
    var testDataManager: DataManager!
    var testDataSource: TestDataSource!

    override func setUp() {
        super.setUp()
        testDataSource = TestDataSource()
        testDataManager = DataManager(dataSource: testDataSource)
    }

    override func tearDown() {
        testDataManager = nil
        testDataSource = nil
        super.tearDown()
    }

    func testLoadData() async throws {
        // When
        await testDataManager.loadData()

        // Then
        XCTAssertEqual(testDataManager.bills.count, 1)
        XCTAssertEqual(testDataManager.legislators.count, 1)
        XCTAssertEqual(testDataManager.legislatorVotes.count, 1)
        XCTAssertEqual(testDataManager.userVotes.count, 0)
        XCTAssertFalse(testDataManager.isLoading)
    }

    func testUpdateBill() async throws {
        // Given
        await testDataManager.loadData()

        // When
        var updatedBill = testDataManager.bills[0]
        updatedBill.userVote = Vote.yes
        try await testDataManager.updateBill(updatedBill)

        // Then
        XCTAssertEqual(testDataManager.bills[0].userVote, Vote.yes)
    }

    func testFetchComments() async throws {
        // Given
        let billId = UUID()
        let comment = Comment(user: "Test User", text: "Test Comment", timestamp: Date(), parentId: nil, replies: [], upvotes: 0, userHasUpvoted: false)
        try await testDataManager.addComment(to: billId, comment: comment)

        // When
        let fetchedComments = try await testDataManager.getComments(for: billId)

        // Then
        XCTAssertEqual(fetchedComments.count, 1)
        XCTAssertEqual(fetchedComments[0].text, "Test Comment")
    }

    func testAddComment() async throws {
        // Given
        let billId = UUID()
        let comment = Comment(user: "Test User", text: "Test Comment", timestamp: Date(), parentId: nil, replies: [], upvotes: 0, userHasUpvoted: false)

        // When
        try await testDataManager.addComment(to: billId, comment: comment)

        // Then
        let fetchedComments = try await testDataManager.getComments(for: billId)
        XCTAssertEqual(fetchedComments.count, 1)
        XCTAssertEqual(fetchedComments[0].text, "Test Comment")
    }
}
