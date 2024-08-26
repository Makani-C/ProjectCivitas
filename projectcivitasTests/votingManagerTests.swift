import XCTest
@testable import projectcivitas

class VotingManagerTests: XCTestCase {
    var votingManager: VotingManager!
    var mockDataSource: MockDataSource!
    var userVotingRecord: UserVotingRecord!

    override func setUpWithError() throws {
        mockDataSource = MockDataSource()
        userVotingRecord = UserVotingRecord()
        votingManager = VotingManager(dataSource: mockDataSource, userVotingRecord: userVotingRecord)
    }

    override func tearDownWithError() throws {
        votingManager = nil
        mockDataSource = nil
        userVotingRecord = nil
    }

    func testFetchBills() async throws {
        // When
        await votingManager.fetchBills()

        // Then
        XCTAssertEqual(votingManager.bills.count, sampleBills.count)
        XCTAssertEqual(votingManager.bills[0].title, sampleBills[0].title)
        XCTAssertEqual(votingManager.bills[1].title, sampleBills[1].title)
    }

    func testVoteForBill() async throws {
        // Given
        await votingManager.fetchBills()
        let bill = votingManager.bills[0]

        // When
        await votingManager.vote(for: bill, vote: .yes)

        // Then
        XCTAssertEqual(votingManager.bills[0].yesVotes, bill.yesVotes + 1)
        XCTAssertEqual(votingManager.bills[0].noVotes, bill.noVotes)
        XCTAssertEqual(votingManager.bills[0].userVote, .yes)
        XCTAssertEqual(userVotingRecord.votes[bill.id], .yes)
    }

    func testChangeVote() async throws {
        // Given
        await votingManager.fetchBills()
        var bill = votingManager.bills[0]
        bill.yesVotes = 1
        bill.userVote = .yes
        try await mockDataSource.updateBill(bill)
        await votingManager.fetchBills()

        // When
        await votingManager.vote(for: bill, vote: .no)

        // Then
        XCTAssertEqual(votingManager.bills[0].yesVotes, 0)
        XCTAssertEqual(votingManager.bills[0].noVotes, 1)
        XCTAssertEqual(votingManager.bills[0].userVote, .no)
        XCTAssertEqual(userVotingRecord.votes[bill.id], .no)
    }

    func testVoteForNonexistentBill() async throws {
        // Given
        let nonexistentBill = Bill(id: UUID(), title: "Nonexistent Bill", description: "Description", state: "WA", body: "Senate", session: "2023", tags: ["Tag"], briefing: "Briefing", yesVotes: 0, noVotes: 0, userVote: nil, comments: [], lastUpdated: Date())

        // When
        await votingManager.vote(for: nonexistentBill, vote: .yes)

        // Then
        XCTAssertEqual(votingManager.bills.count, sampleBills.count)
        XCTAssertNil(userVotingRecord.votes[nonexistentBill.id])
    }
}
