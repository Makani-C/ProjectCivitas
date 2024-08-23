//
//  SampleData.swift
//  projectcivitas
//
//  Created by Makani Cartwright on 8/22/24.
//

import Foundation

let sampleComments = [
    Comment(user: "John Doe", text: "This bill seems promising.", timestamp: Date().addingTimeInterval(-86400), replies: [], parentId: nil),
    Comment(user: "Jane Smith", text: "I have concerns about Section 3.", timestamp: Date().addingTimeInterval(-43200), replies: [], parentId: nil),
    Comment(user: "Bob Vance", text: "How will this affect small businesses?", timestamp: Date().addingTimeInterval(-21600), replies: [], parentId: nil)
]

let sampleBills = [
    Bill(
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
        comments: sampleComments
    ),
    Bill(
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
        comments: []
    ),
    Bill(
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
        comments: []
    ),
    Bill(title: "House Bill 1002",
         description: "Increases the penalty for hazing",
         state: "WA",
         body: "House",
         session: "2023",
         tags: ["Education", "Criminal Justice"],
         briefing: "This bill proposes increasing penalties for hazing incidents.",
         yesVotes: 120,
         noVotes: 80,
         userVote: nil,
         comments: []
        ),
    Bill(title: "Senate Bill 5020",
         description: "Proposes changing the starting age for elementary education to six years old",
         state: "WA",
         body: "Senate",
         session: "2023",
         tags: ["Education"],
         briefing: "This bill proposes changing the starting age for elementary education to six years old.",
         yesVotes: 120,
         noVotes: 80,
         userVote: nil,
         comments: []
        ),
    Bill(title: "House Resolution 503",
         description: "Proposes articles of impeachment against President Biden",
         state: "US",
         body: "House of Representatives",
         session: "2023",
         tags: ["Federal", "Impeachment"],
         briefing: "This resolution proposes articles of impeachment against President Biden.",
         yesVotes: 120,
         noVotes: 80,
         userVote: nil,
         comments: []
        ),
    Bill(title: "Senate Bill 1323",
         description: "Provides for banking for cannabis companies",
         state: "US",
         body: "Senate",
         session: "2023",
         tags: ["Banking", "Cannabis"],
         briefing: "This bill aims to provide banking services for cannabis companies.",
         yesVotes: 120,
         noVotes: 80,
         userVote: nil,
         comments: []
        ),
]

let sampleLegislators = [
    Legislator(
        name: "John Smith",
        party: "Democrat",
        state: "California",
        district: "12th",
        chamber: "House of Representatives",
        imageUrl: "https://example.com/john_smith.jpg",
        biography: "John Smith has served in the House of Representatives since 2015...",
        topIssues: ["Climate Change", "Healthcare Reform", "Education"],
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
            VotingRecord(billTitle: "H.R. 1 - For the People Act", vote: "Yea", date: Date()),
            VotingRecord(billTitle: "H.R. 3 - Lower Drug Costs Now Act", vote: "Yea", date: Date().addingTimeInterval(-86400)),
            // Add more voting records...
        ]
    ),
]
