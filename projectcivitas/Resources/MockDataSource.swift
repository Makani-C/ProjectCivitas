import Foundation
import SwiftUI

class MockDataSource: DataSourceProtocol {

    private var bills: [Bill]
    private var legislators: [Legislator]
    private var legislatorVotes: [LegislatorVote]
    private var userVotes: [UserVote]
    private var comments: [UUID: [Comment]]

    init() {
        self.bills = MockDataSource.createSampleBills()
        self.legislators = MockDataSource.createSampleLegislators()
        self.legislatorVotes = MockDataSource.createSampleVotes(bills: self.bills, legislators: self.legislators)
        self.userVotes = []
        self.comments = MockDataSource.createSampleComments(bills: self.bills)
    }

    func fetchBills() async throws -> [Bill] {
        return bills
    }

    func fetchLegislators() async throws -> [Legislator] {
        return legislators
    }
    
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
        if let bill = bills.first(where: { $0.id == billId }) {
            return bill.briefing
        }
        throw NSError(domain: "BillNotFound", code: 404, userInfo: nil)
    }
    // MARK: - Sample Data Creation

    private static func createSampleBills() -> [Bill] {
        return [
            Bill(
                id: UUID(),
                title: "House Joint Resolution 11",
                description: "Constitutional amendment for Congressional term limits",
                state: "US",
                body: "House of Representatives",
                session: "2023",
                tags: ["Congress", "Constitutional Amendment"],
                briefing: "This joint resolution proposes an amendment to the US Constitution to limit the number of terms a Member of Congress may serve. Representatives would be limited to three terms and Senators to two terms. Vacancies filled for more than one year and three years, respectively, would be included in the term count. The amendment has been proposed by Mr. Norman and has been co-sponsored by members of the Virginia House of Delegates, as well as members from New York, Pennsylvania, South Carolina, Iowa, Illinois, and other states. Terms beginning before the ratification of this article would not be taken into account.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
            Bill(
                id: UUID(),
                title: "Senate Bill 5047",
                description: "Enhances the Washington Voting Rights Act",
                state: "WA",
                body: "Senate",
                session: "2023",
                tags: ["Voting Rights", "Washington"],
                briefing: "This bill aims to enhance the Washington Voting Rights Act.",
                lastUpdated: Date(),
                yesVotes: 0,
                noVotes: 0,
                userVote: nil
            ),
            Bill(
                
                id: UUID(),
                title: "House Bill 1001",
                description: "Audiology and Speech-Language Pathology Interstate Compact",
                state: "WA",
                body: "House",
                session: "2023",
                tags: ["Healthcare", "Interstate Compact"],
                briefing: "This bill proposes joining the Audiology and Speech-Language Pathology Interstate Compact.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
            Bill(
                id: UUID(),
                title: "House Bill 1002",
                description: "Increases the penalty for hazing",
                state: "WA",
                body: "House",
                session: "2023",
                tags: ["Education", "Criminal Justice"],
                briefing: "This bill proposes increasing penalties for hazing incidents.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
            Bill(
                id: UUID(),
                title: "Senate Bill 5020",
                description: "Proposes changing the starting age for elementary education to six years old",
                state: "WA",
                body: "Senate",
                session: "2023",
                tags: ["Education"],
                briefing: "This bill proposes changing the starting age for elementary education to six years old.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
            Bill(
                id: UUID(),
                title: "House Resolution 503",
                description: "Proposes articles of impeachment against President Biden",
                state: "US",
                body: "House of Representatives",
                session: "2023",
                tags: ["Federal", "Impeachment"],
                briefing: "This resolution proposes articles of impeachment against President Biden.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
            Bill(
                id: UUID(),
                title: "Senate Bill 1323",
                description: "Provides for banking for cannabis companies",
                state: "US",
                body: "Senate",
                session: "2023",
                tags: ["Banking", "Cannabis"],
                briefing: "This bill aims to provide banking services for cannabis companies.",
                lastUpdated: Date(),
                yesVotes: 120,
                noVotes: 80,
                userVote: nil
            ),
        ]
    }

    private static func createSampleLegislators() -> [Legislator] {
        return [
            Legislator(
                id: UUID(),
                name: "John Smith",
                party: "Democrat",
                state: "WA",
                district: "98th",
                chamber: "House of Representatives",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Labor", "Education"],
                contactInfo: ContactInfo(
                    email: "john.smith@house.gov",
                    phone: "(202) 555-0123",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "repjohnsmith",
                    facebook: "RepJohnSmith",
                    instagram: "repjohnsmith"
                ),
                fundingRecord: [
                    FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
                    FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
                    FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
                ]
            ),
            Legislator(
                id: UUID(),
                name: "Jane Doe",
                party: "Democrat",
                state: "WA",
                district: "99th",
                chamber: "House of Representatives",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Climate Change", "Healthcare Reform"],
                contactInfo: ContactInfo(
                    email: "jane.doe@house.gov",
                    phone: "(202) 555-0123",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "repJaneDoe",
                    facebook: "repJaneDoe",
                    instagram: "repJaneDoe"
                ),
                fundingRecord: [
                    FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
                    FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
                    FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
                ]
            ),
            Legislator(
                id: UUID(),
                name: "Peter Abbarno",
                party: "Republican",
                state: "WA",
                district: "20th",
                chamber: "House",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Public Safety", "Parental Rights"],
                contactInfo: ContactInfo(
                    email: "peter.abbarno@house.wa.gov",
                    phone: "(360) 000-0000",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "reppabb",
                    facebook: "reppabb",
                    instagram: "reppabb"
                ),
                fundingRecord: [
                    FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
                    FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
                    FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
                ]
            ),
            Legislator(
                id: UUID(),
                name: "Dan Newhouse",
                party: "Republican",
                state: "US",
                district: "WA",
                chamber: "House",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Immigration", "Ukraine"],
                contactInfo: ContactInfo(
                    email: "dn@house.gov",
                    phone: "(360) 000-0003",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "repNewhouse",
                    facebook: "repNewhouse",
                    instagram: "repNewhouse"
                ),
                fundingRecord: []
            ),
            Legislator(
                id: UUID(),
                name: "Marie Glusenkamp-Perez",
                party: "Democrat",
                state: "US",
                district: "WA",
                chamber: "House",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Labor", "Immigration", "Infrastructure"],
                contactInfo: ContactInfo(
                    email: "mgp@house.gov",
                    phone: "(360) 000-0002",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "repmarieGP",
                    facebook: "repmarieGP",
                    instagram: "@repMarieGP"
                ),
                fundingRecord: []
            ),
            Legislator(
                id: UUID(),
                name: "Maria Cantwell",
                party: "Democrat",
                state: "US",
                district: "WA",
                chamber: "Senate",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Climate Change", "Healthcare Reform", "Education"],
                contactInfo: ContactInfo(
                    email: "maria.cantwell@congress.gov",
                    phone: "(360) 000-0001",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "senatorCantwell",
                    facebook: "senatorCantwell",
                    instagram: "@senatorCantwell"
                ),
                fundingRecord: []
            ),
            Legislator(
                id: UUID(),
                name: "Patty Murray",
                party: "Democrat",
                state: "US",
                district: "WA",
                chamber: "Senate",
                imageUrl: "https://example.com/john_smith.jpg",
                topIssues: ["Climate Change", "Healthcare Reform", "Education"],
                contactInfo: ContactInfo(
                    email: "patty.murray@congress.gov",
                    phone: "(360) 000-0000",
                    office: "123 Capitol Hill, Washington D.C."
                ),
                socialMedia: SocialMedia(
                    twitter: "senatorPMurray",
                    facebook: "senatorPMurray",
                    instagram: "@senatorMurray"
                ),
                fundingRecord: []
            ),
        ]
    }

    private static func createSampleVotes(bills: [Bill], legislators: [Legislator]) -> [LegislatorVote] {
        var records: [LegislatorVote] = []
        
        for (index, bill) in bills.enumerated() {
            for (legIndex, legislator) in legislators.enumerated() {
                let vote: Vote = [Vote.yes, Vote.no, Vote.abstain, Vote.notPresent][Int.random(in: 0...3)]
                let record = LegislatorVote(
                    id: UUID(),
                    billId: bill.id,
                    legislatorId: legislator.id,
                    vote: vote,
                    date: Date().addingTimeInterval(Double(-86400 * (index + legIndex)))
                )
                records.append(record)
            }
        }
        
        return records
    }


    private static func createSampleComments(bills: [Bill]) -> [UUID: [Comment]] {
        var allComments: [UUID: [Comment]] = [:]
        
        for bill in bills {
            let comments = [
                Comment(
                    user: "John Doe",
                    text: "This bill seems promising. I particularly like the focus on environmental protection.",
                    timestamp: Date().addingTimeInterval(-86400),
                    parentId: nil,
                    replies: [],
                    upvotes: 10,
                    userHasUpvoted: false
                ),
                Comment(
                    user: "Jane Smith",
                    text: "I agree, but I'm concerned about the potential economic impact. Has there been an analysis?",
                    timestamp: Date().addingTimeInterval(-82800),
                    parentId: nil,
                    replies: [],
                    upvotes: 5,
                    userHasUpvoted: false
                ),
            ]
            allComments[bill.id] = comments
        }
        
        return allComments
    }
}
