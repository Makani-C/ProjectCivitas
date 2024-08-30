//
//  BillViews.swift
//

import Foundation
import SwiftUI

struct BillFilteredList: View {
    @ObservedObject var filterManager: FilterManager<Bill>
    @EnvironmentObject var dataManager: DataManager
    
    let sortOptions = ["Updated", "Title", "Popularity"]
    
    var filterCategories: [FilterCategory<Bill>] {
        [
            FilterCategory(name: "Tags", key: "tags", values: Array(Set(dataManager.bills.flatMap { $0.tags }))),
            FilterCategory(name: "Sessions", key: "sessions", values: Array(Set(dataManager.bills.map { $0.session }))),
            FilterCategory(name: "Bodies", key: "bodies", values: Array(Set(dataManager.bills.map { $0.body }))),
            FilterCategory(name: "Followed Only", key: "followed", values: ["true", "false"])
        ]
    }
    
    var body: some View {
        FilteredList(filterManager: filterManager, sortOptions: sortOptions, filterCategories: filterCategories)
    }
}

struct BillRow: View {
    let bill: Bill
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var voteManager: VoteManager
    
    var body: some View {
        NavigationLink(destination: BillDetailPage(billId: bill.id)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(bill.state)
                        .font(.headline)
                        .foregroundColor(.red)
                        .lineLimit(1)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Text(bill.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    FollowStar(isFollowed: settingsManager.isFollowing(bill))
                }
                
                Text(bill.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(CustomNavigationLinkStyle())
        Divider()
    }
}

struct BillDetailPage: View {
    @StateObject private var viewModel: BillDetailViewModel
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var voteManager: VoteManager
    
    @State private var voteButtonScale: CGFloat = 1.0
    
    init(billId: UUID) {
        _viewModel = StateObject(wrappedValue: BillDetailViewModel(billId: billId))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoadingBill {
                ProgressView()
            } else if let bill = viewModel.bill {
                VStack(spacing: 0) {
                    billHeader(bill: bill)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            citizenOpinionSection(bill: bill)
                            votingSection(bill: bill)
                            Divider()
                            citizensBriefingSection(bill: bill)
                            Divider()
                            votingRecordSection(legislatorVotes: voteManager.getLegislatorVotes(for: bill.id))
                            Divider()
                            commentSection(bill: bill)
                        }
                        .padding()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: BackButton(), trailing: FollowButton(settingsManager: settingsManager, item: bill))
                .sheet(isPresented: $viewModel.showingAddComment) {
                    AddCommentModal(billId: bill.id, parentId: nil, onCommentAdded: {
                        Task {
                            await viewModel.fetchComments(dataManager: dataManager)
                        }
                    })
                }
                .sheet(isPresented: $viewModel.showingFullText) {
                    FullBillTextView(text: bill.briefing)
                }
                .task {
                    await viewModel.fetchComments(dataManager: dataManager)
                }

                if viewModel.showingCelebration, let vote = viewModel.celebratedVote {
                    CelebrateVoteView(vote: vote, isPresented: $viewModel.showingCelebration)
                }
            } else {
                Text("Bill not found")
            }
        }
        .task {
            await viewModel.fetchBill(dataManager: dataManager)
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private func billHeader(bill: Bill) -> some View {
        HeaderView {
            HStack {
                Text(bill.state)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
            Text(bill.title).font(.title)
                .bold()
                .foregroundColor(.white)
            Text("Body: \(bill.body)").font(.subheadline).foregroundColor(.white)
            Text("Session: \(bill.session)").font(.subheadline).foregroundColor(.white)
            tagScrollView(tags: bill.tags)
        }
    }
    
    private func tagScrollView(tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Tags:").font(.subheadline)
                    .foregroundColor(.white)
                ForEach(tags, id: \.self) { TagChip(title: $0) }
            }
        }
    }
    
    private func citizenOpinionSection(bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Citizens Opinion").font(.headline).foregroundColor(.oldGloryRed)
            HStack {
                Text("Yes: \(bill.yesVotes)")
                Spacer()
                Text("No: \(bill.noVotes)")
            }
            VoteDistributionBar(yesVotes: bill.yesVotes, noVotes: bill.noVotes)
        }
    }
    
    private func votingSection(bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VoteButton(title: "Vote Yes", color: .fruitSaladGreen, action: {
                    Task {
                        await viewModel.vote(.yes, voteManager: voteManager, dataManager: dataManager)
                    }
                }, isSelected: bill.userVote == .yes)
                VoteButton(title: "Vote No", color: .oldGloryRed, action: {
                    Task {
                        await viewModel.vote(.no, voteManager: voteManager, dataManager: dataManager)
                    }
                }, isSelected: bill.userVote == .no)
            }
        }
    }
    
    private func citizensBriefingSection(bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Citizens Briefing").font(.headline).fontWeight(.bold).foregroundColor(.oldGloryRed)
                Spacer()
                Button("See Full text") {
                    viewModel.showingFullText = true
                }
            }
            Text("This summary is generated by AI and may contain inaccuracies. Please refer to the full text for official information, and contact us to report any errors.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(bill.briefing).font(.body)
        }
    }
    
    private func votingRecordSection(legislatorVotes: [LegislatorVote]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legislator Voting Record")
                .font(.headline)
                .foregroundColor(.oldGloryRed)

            if legislatorVotes.isEmpty {
                Text("No voting records available for this bill.")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 0) {
                    TableHeader(headers: ["Legislator", "Vote", "Date"])
                    
                    ForEach(legislatorVotes) { vote in
                        TableRow {
                            if let legislator = dataManager.legislators.first(where: { $0.id == vote.legislatorId }) {
                                Text(legislator.name)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Unknown Legislator")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(vote.vote.rawValue.capitalized)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text(vote.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func commentSection(bill: Bill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Comments")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.oldGloryRed)
                Spacer()
                Button("Add Comment") { viewModel.showingAddComment = true }
            }
            
            if viewModel.isLoadingComments {
                ProgressView()
            } else if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                CommentsList(comments: viewModel.comments, billId: bill.id, parentId: nil, level: 0)
            }
        }
    }
}

struct FullBillTextView: View {
    let text: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .padding()
            }
            .navigationBarTitle("Full Bill Text", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
