//
//  FeedView.swift
//

import SwiftUI

struct FeedItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let associatedItems: [AssociatedItem]
    let tags: [String]
}

struct AssociatedItem: Identifiable {
    let id = UUID()
    let type: AssociatedItemType
    let itemId: UUID
    let title: String
}

enum AssociatedItemType {
    case bill
    case legislator
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView {
                    Text("Feed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Divider().background(.white).bold()
                    TagFilterView(allTags: viewModel.allTags, selectedTags: $viewModel.selectedTags)
                }
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredFeedItems) { item in
                            FeedItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.loadFeedItems()
        }
    }
}

struct TagFilterView: View {
    let allTags: [String]
    @Binding var selectedTags: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Text("Tags").foregroundColor(.white).bold().padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(allTags, id: \.self) { tag in
                        TagFilterButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
            }
        })
    }
}

class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var selectedTags: Set<String> = []
    
    var allTags: [String] {
        Array(Set(feedItems.flatMap { $0.tags })).sorted()
    }
    
    var filteredFeedItems: [FeedItem] {
        if selectedTags.isEmpty {
            return feedItems
        } else {
            return feedItems.filter { item in
                !selectedTags.isDisjoint(with: Set(item.tags))
            }
        }
    }
    
    func loadFeedItems() {
        // TODO: Replace this with actual API call
        feedItems = [
            FeedItem(
                title: "New Bill Introduced",
                description: "A new bill on environmental protection has been introduced.",
                date: Date(),
                associatedItems: [
                    AssociatedItem(type: .bill, itemId: UUID(), title: "EPA Bill"),
                ],
                tags: ["Environment", "New Legislation"]
            ),
            FeedItem(
                title: "Legislator Vote",
                description: "Your Congressperson has voted on a bill you were following",
                date: Date(),
                associatedItems: [
                    AssociatedItem(type: .legislator, itemId: UUID(), title: "TEST"),
                ],
                tags: ["California"]
            ),
        ]
    }
}

struct TagFilterButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? .white : Color.gray.opacity(0.8))
                .foregroundColor(isSelected ? .oldGloryRed : .oldGloryBlue)
                .cornerRadius(15)
        }
    }
}

struct FeedItemView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.oldGloryRed)
            Text(item.description)
                .font(.subheadline)
            Text(item.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                ForEach(item.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.oldGloryBlue.opacity(0.1))
                        .foregroundColor(.oldGloryBlue)
                        .cornerRadius(8)
                }
            }
            
            AssociatedItemsCarousel(items: item.associatedItems)
        }
        .padding()
        .cornerRadius(10)
    }
}

struct AssociatedItemsCarousel: View {
    let items: [AssociatedItem]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                        ForEach(items.indices, id: \.self) { index in
                            AssociatedItemCard(item: items[index])
                                .id(index)
                        }
                    }
                    .padding(.trailing, 40) // Add extra padding to show partial next card
                }
#if compiler(>=5.9)
                .onChange(of: currentIndex) { oldIndex, newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .leading)
                    }
                }
#else
                .onChange(of: currentIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .leading)
                    }
                }
#endif
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                .frame(width: 40)
                .position(x: UIScreen.main.bounds.width - 20, y: 75)
        )
    }
}

struct AssociatedItemCard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var voteManager: VoteManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    let item: AssociatedItem
    
    var body: some View {
        NavigationLink(destination: destinationView(for: item)) {
            HStack(spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .foregroundColor(.oldGloryBlue)
                    .underline()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func destinationView(for item: AssociatedItem) -> some View {
        switch item.type {
        case .bill:
            if let bill = dataManager.bills.first(where: { $0.id == item.itemId }) {
                BillDetailPage(billId: bill.id)
            } else {
                Text("Bill not found")
            }
        case .legislator:
            if let legislator = dataManager.legislators.first(where: { $0.id == item.itemId }) {
                LegislatorDetailPage(legislator: legislator)
            } else {
                Text("Legislator not found")
            }
        }
    }
}
