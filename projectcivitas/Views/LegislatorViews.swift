//
// LegislatorViews.swift
//

import SwiftUI

struct LegislatorFilteredList: View {
    @ObservedObject var filterManager: FilterManager<Legislator>
    @EnvironmentObject var dataManager: DataManager
    
    
    let sortOptions = ["Name", "State", "Party"]
    
    var filterCategories: [FilterCategory<Legislator>] {
        [
            FilterCategory(name: "Parties", key: "parties", values: Array(Set(dataManager.legislators.map { $0.party }))),
            FilterCategory(name: "States", key: "states", values: Array(Set(dataManager.legislators.map { $0.state }))),
            FilterCategory(name: "Chambers", key: "chambers", values: Array(Set(dataManager.legislators.map { $0.chamber }))),
            FilterCategory(name: "Followed Only", key: "followed", values: ["true", "false"])
        ]
    }
    
    var body: some View {
        FilteredList(filterManager: filterManager, sortOptions: sortOptions, filterCategories: filterCategories)
    }
}

struct LegislatorRow: View {
    let legislator: Legislator
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: legislator.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(legislator.name).font(.headline).foregroundColor(.oldGloryRed)
                    FollowStar(isFollowed: settingsManager.isFollowing(legislator))
                }
                Text("\(legislator.party) - \(legislator.state)").font(.subheadline)
                Text(legislator.chamber).font(.caption)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
    }
}

struct LegislatorDetailPage: View {
    let legislator: Legislator
    @EnvironmentObject var votingManager: VoteManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 0) {
            legislatorHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScoreSection(
                        attendanceScore: votingManager.getLegislatorAttendanceScore(for: legislator.id),
                        alignmentScore: votingManager.getUserLegislatorAlignmentScore(legislatorId: legislator.id, userId: settingsManager.userId)
                    )
                    InfoSection("Top Issues") {
                        ForEach(legislator.topIssues, id: \.self) { Text("• \($0)") }
                    }
                    ContactInfoSection(contactInfo: legislator.contactInfo)
                    SocialMediaSection(socialMedia: legislator.socialMedia)
                    VotingRecordSection(legislatorVotes: votingManager.getLegislatorVotingRecord(for: legislator.id), bills: dataManager.bills)
                    FundingRecordSection(fundingRecord: legislator.fundingRecord)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(), trailing: FollowButton(settingsManager: settingsManager, item: legislator))
    }
    
    private var legislatorHeader: some View {
        HeaderView {
            AsyncImage(url: URL(string: legislator.imageUrl)) { $0.resizable() } placeholder: { Color.gray }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            Text(legislator.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("\(legislator.party) - \(legislator.state)").font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            if let district = legislator.district {
                Text("\(district) District").font(.subheadline)
                    .foregroundColor(.white)
            }
            Text(legislator.chamber).font(.subheadline)
                .foregroundColor(.white)
        }
    }
    
    struct ScoreSection: View {
        let attendanceScore: Double?
        let alignmentScore: Double?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Attendance Score: \(scoreText(attendanceScore))")
                    .font(.headline)
                Text("Alignment Score: \(scoreText(alignmentScore))")
                    .font(.headline)
            }
        }
        
        private func scoreText(_ score: Double?) -> String {
            if let score = score {
                return String(format: "%.0f%%", score)
            } else {
                return "N/A"
            }
        }
    }
    
    struct ContactInfoSection: View {
        let contactInfo: ContactInfo
        
        var body: some View {
            InfoSection("Contact Information") {
                Text("Email: \(contactInfo.email)")
                Text("Phone: \(contactInfo.phone)")
                Text("Office: \(contactInfo.office)")
            }
        }
    }
    
    struct SocialMediaSection: View {
        let socialMedia: SocialMedia
        
        var body: some View {
            InfoSection("Social Media") {
                if let twitter = socialMedia.twitter { Text("Twitter: @\(twitter)") }
                if let facebook = socialMedia.facebook { Text("Facebook: \(facebook)") }
                if let instagram = socialMedia.instagram { Text("Instagram: @\(instagram)") }
            }
        }
    }
    
    struct VotingRecordSection: View {
        let legislatorVotes: [LegislatorVote]
        let bills: [Bill]
        
        var body: some View {
            InfoSection("Recent Voting Record") {
                VStack(spacing: 0) {
                    TableHeader(headers: ["Bill", "Vote", "Date"])
                    ForEach(legislatorVotes.prefix(5)) { legislatorVote in
                        TableRow {
                            if let bill = bills.first(where: { $0.id == legislatorVote.billId }) {
                                Text(bill.title)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Unknown Bill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(legislatorVote.vote.rawValue)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(legislatorVote.date, formatter: itemFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                if legislatorVotes.count > 5 {
                    Button("See full voting record") {
                        // Implement navigation to full voting record view
                    }
                    .font(.caption)
                    .foregroundColor(.oldGloryBlue)
                    .padding(.top, 8)
                }
            }
        }
        
        private let itemFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    }
    
    struct FundingRecordSection: View {
        let fundingRecord: [FundingRecord]
        
        var body: some View {
            InfoSection("Funding Record") {
                VStack(spacing: 0) {
                    TableHeader(headers: ["Source", "Amount", "Date"])
                    
                    ForEach(fundingRecord.prefix(5)) { record in
                        TableRow {
                            Text(record.source)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("$\(String(format: "%.2f", record.amount))")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(record.date, formatter: itemFormatter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                if fundingRecord.count > 5 {
                    Button("See all funding records") {
                        // Implement navigation to full funding record view
                    }
                    .font(.caption)
                    .foregroundColor(.oldGloryBlue)
                    .padding(.top, 8)
                }
            }
        }
        
        private let itemFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    }
}
