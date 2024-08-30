//
//  BillDetailViewModelTests.swift
//

import XCTest
@testable import projectcivitas

class BillDetailViewModelTests: XCTestCase {
    var viewModel: BillDetailViewModel!
    var testDataManager: DataManager!
    var testVoteManager: VoteManager!
    var testDataSource: TestDataSource!
    var testBillId: UUID!
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
        
        testBillId = testDataManager.bills[0].id
        viewModel = BillDetailViewModel(billId: testBillId)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        testDataSource = nil
        testDataManager = nil
        testVoteManager = nil
        try super.tearDownWithError()
    }
    
    func testFetchBill() async throws {
        // Given
        XCTAssertNil(viewModel.bill)
        XCTAssertFalse(viewModel.isLoadingBill)
        
        // When
        await viewModel.fetchBill(dataManager: testDataManager)
        
        // Then
        XCTAssertNotNil(viewModel.bill)
        XCTAssertEqual(viewModel.bill?.id, testBillId)
        XCTAssertFalse(viewModel.isLoadingBill)
    }
    
    func testFetchComments() async throws {
        // Given
        XCTAssertTrue(viewModel.comments.isEmpty)
        XCTAssertFalse(viewModel.isLoadingComments)
        
        // When
        try await testDataManager.addComment(to: testBillId, comment: Comment(user: "Test", text: "Test", timestamp: Date(), parentId: nil, replies: [], upvotes: 0, userHasUpvoted: false))
        await viewModel.fetchComments(dataManager: testDataManager)
        
        // Then
        XCTAssertFalse(viewModel.comments.isEmpty)
        XCTAssertFalse(viewModel.isLoadingComments)
    }
    
    func testVote() async throws {
        // Given
        await viewModel.fetchBill(dataManager: testDataManager)
        XCTAssertNotNil(viewModel.bill)
        
        // When
        await viewModel.vote(.yes, votingManager: testVoteManager, dataManager: testDataManager)
        
        // Then
        XCTAssertEqual(viewModel.celebratedVote, .yes)
        XCTAssertTrue(viewModel.showingCelebration)
    }
    
    func testVoteError() async throws {
        // Given
        await viewModel.fetchBill(dataManager: testDataManager)
        XCTAssertNotNil(viewModel.bill)
        
        // Simulate an error
        testVoteManager = ErrorVoteManager(userId: testUserId, dataManager: testDataManager)
        
        // When
        await viewModel.vote(.yes, votingManager: testVoteManager, dataManager: testDataManager)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.showingCelebration)
    }
}

// Mock VoteManager that always throws an error
class ErrorVoteManager: VoteManager {
    override func castVote(for bill: Bill, vote: Vote) async throws {
        throw VotingError.billNotFound
    }
}
