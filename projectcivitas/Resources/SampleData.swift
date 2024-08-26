//
//  SampleData.swift
//

import Foundation

let sampleComments = [
    Comment(
        user: "John Doe",
        text: "This bill seems promising. I particularly like the focus on environmental protection.",
        timestamp: Date().addingTimeInterval(-86400),
        parentId: nil,
        replies: [
            Comment(
                user: "Jane Smith",
                text: "I agree, but I'm concerned about the potential economic impact. Has there been an analysis?",
                timestamp: Date().addingTimeInterval(-82800),
                parentId: nil,
                replies: [],
                upvotes: 5,
                userHasUpvoted: false
            ),
            Comment(
                user: "Bob Johnson",
                text: "Good point, Jane. I'd also like to see more details on implementation timelines.",
                timestamp: Date().addingTimeInterval(-79200),
                parentId: nil,
                replies: [],
                upvotes: 2,
                userHasUpvoted: false
            )
        ],
        upvotes: 10,
        userHasUpvoted: false
    ),
    Comment(
        user: "Alice Brown",
        text: "I have concerns about Section 3. It seems too vague and could lead to misinterpretation.",
        timestamp: Date().addingTimeInterval(-72000),
        parentId: nil,
        replies: [
            Comment(
                user: "Charlie Davis",
                text: "I see your point, Alice. Perhaps we should suggest more specific language for that section.",
                timestamp: Date().addingTimeInterval(-68400),
                parentId: nil,
                replies: [],
                upvotes: 3,
                userHasUpvoted: false
            )
        ],
        upvotes: 7,
        userHasUpvoted: false
    ),
    Comment(
        user: "Eva Wilson",
        text: "How will this bill affect small businesses? I'm worried it might impose too much of a burden.",
        timestamp: Date().addingTimeInterval(-57600),
        parentId: nil,
        replies: [],
        upvotes: 8,
        userHasUpvoted: false
    )
]

let sampleBills = [
    Bill(
        id: UUID(),
        title: "House Joint Resolution 11",
        description: "Constitutional amendment for Congressional term limits",
        state: "US",
        body: "House of Representatives",
        session: "2023",
        tags: ["Congress", "Constitutional Amendment"],
        briefing: "This joint resolution proposes an amendment to the US Constitution to limit the number of terms a Member of Congress may serve. Representatives would be limited to three terms and Senators to two terms. Vacancies filled for more than one year and three years, respectively, would be included in the term count. The amendment has been proposed by Mr. Norman and has been co-sponsored by members of the Virginia House of Delegates, as well as members from New York, Pennsylvania, South Carolina, Iowa, Illinois, and other states. Terms beginning before the ratification of this article would not be taken into account.",
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: sampleComments,
        lastUpdated: Date()
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
        yesVotes: 0,
        noVotes: 0,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
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
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
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
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
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
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
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
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
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
        yesVotes: 120,
        noVotes: 80,
        userVote: nil,
        comments: [],
        lastUpdated: Date()
    ),
]

let sampleLegislators = [
    Legislator(
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
        votingRecord: [
            VotingRecord(billId: sampleBills[0].id, vote: .yes, date: Date()),
            VotingRecord(billId: sampleBills[1].id, vote: .no, date: Date().addingTimeInterval(-86400)),
            VotingRecord(billId: sampleBills[2].id, vote: .yes, date: Date().addingTimeInterval(-172800)),
            VotingRecord(billId: sampleBills[3].id, vote: .notPresent, date: Date().addingTimeInterval(-172800)),
        ],
        fundingRecord: [
            FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
            FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
            FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
        ]
    ),
    Legislator(
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
        votingRecord: [
            VotingRecord(billId: sampleBills[0].id, vote: .yes, date: Date()),
            VotingRecord(billId: sampleBills[1].id, vote: .no, date: Date().addingTimeInterval(-86400)),
            VotingRecord(billId: sampleBills[2].id, vote: .yes, date: Date().addingTimeInterval(-172800)),
            VotingRecord(billId: sampleBills[3].id, vote: .notPresent, date: Date().addingTimeInterval(-172800)),
        ],
        fundingRecord: [
            FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
            FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
            FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
        ]
    ),
    Legislator(
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
        votingRecord: [
            VotingRecord(billId: sampleBills[0].id, vote: .yes, date: Date()),
            VotingRecord(billId: sampleBills[1].id, vote: .no, date: Date().addingTimeInterval(-86400)),
            VotingRecord(billId: sampleBills[2].id, vote: .yes, date: Date().addingTimeInterval(-172800)),
            VotingRecord(billId: sampleBills[3].id, vote: .notPresent, date: Date().addingTimeInterval(-172800)),
        ],
        fundingRecord: [
            FundingRecord(source: "Individual Contributions", amount: 500000, date: Date()),
            FundingRecord(source: "PAC Contributions", amount: 250000, date: Date().addingTimeInterval(-86400)),
            FundingRecord(source: "Self-Funding", amount: 100000, date: Date().addingTimeInterval(-172800))
        ]
    ),
    Legislator(
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
        votingRecord: [],
        fundingRecord: []
    ),
    Legislator(
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
        votingRecord: [],
        fundingRecord: []
    ),
    Legislator(
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
        votingRecord: [],
        fundingRecord: []
    ),
    Legislator(
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
        votingRecord: [],
        fundingRecord: []
    ),
]
