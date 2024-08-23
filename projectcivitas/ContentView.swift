import SwiftUI

import SwiftUI

// MARK: - Feed

struct FeedItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let associatedItems: [AssociatedItem]
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
    @State private var feedItems: [FeedItem] = [
        FeedItem(
            title: "New Bill Introduced",
            description: "A new bill on environmental protection has been introduced.",
            date: Date(),
            associatedItems: [
                AssociatedItem(type: .bill, itemId: UUID(), title: "EPA Bill"),
            ]
        ),
        FeedItem(
            title: "Legislator Update",
            description: "Senator Smith has updated their voting record.",
            date: Date(),
            associatedItems: [
                AssociatedItem(type: .legislator, itemId: sampleLegislators[0].id, title: sampleLegislators[0].name),
            ]
        ),
        FeedItem(
            title: "New Environmental Protection Bills",
            description: "Multiple bills on environmental protection have been introduced.",
            date: Date(),
            associatedItems: [
                AssociatedItem(type: .bill, itemId: UUID(), title: "EPA Bill"),
                AssociatedItem(type: .bill, itemId: UUID(), title: "WWC Bill")
            ]
        ),
        FeedItem(
            title: "Legislators Update Voting Records",
            description: "Several legislators have updated their voting records.",
            date: Date(),
            associatedItems: [
                AssociatedItem(type: .legislator, itemId: sampleLegislators[0].id, title: sampleLegislators[0].name),
                AssociatedItem(type: .legislator, itemId: sampleLegislators[1].id, title: sampleLegislators[1].name),
                AssociatedItem(type: .legislator, itemId: sampleLegislators[2].id, title: sampleLegislators[2].name),
                AssociatedItem(type: .legislator, itemId: sampleLegislators[3].id, title: sampleLegislators[3].name),
                AssociatedItem(type: .legislator, itemId: sampleLegislators[4].id, title: sampleLegislators[4].name),
                AssociatedItem(type: .legislator, itemId: sampleLegislators[5].id, title: sampleLegislators[5].name),
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView {
                    Text("Feed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(feedItems) { item in
                            FeedItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeedItemView: View {
    let item: FeedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
            Text(item.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            AssociatedItemsCarousel(items: item.associatedItems)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
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
                .onChange(of: currentIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .leading)
                    }
                }
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
            if let bill = sampleBills.first(where: { $0.id == item.itemId }) {
                BillDetailPage(bill: bill)
            } else {
                Text("Bill not found")
            }
        case .legislator:
            if let legislator = sampleLegislators.first(where: { $0.id == item.itemId }) {
                LegislatorDetailPage(legislator: legislator)
            } else {
                Text("Legislator not found")
            }
        }
    }
}

// MARK: - Catalog

struct CatalogPage: View {
    @EnvironmentObject var votingManager: VotingManager
    @State private var selectedTab: CatalogTab = .bills
    @StateObject private var billFilterManager = FilterManager<Bill>(
        initialSortOption: "Updated",
        sortKeyPath: { sortOption in
            switch sortOption {
            case "Updated":
                return { $0.lastUpdated > $1.lastUpdated }
            case "Title":
                return { $0.title < $1.title }
            case "Popularity":
                return { $0.yesVotes + $0.noVotes > $1.yesVotes + $1.noVotes }
            default:
                return { $0.lastUpdated > $1.lastUpdated }
            }
        }
    )
    @StateObject private var legislatorFilterManager = FilterManager<Legislator>(
        initialSortOption: "Name",
        sortKeyPath: { sortOption in
            switch sortOption {
            case "Name":
                return { $0.name < $1.name }
            case "State":
                return { $0.state < $1.state }
            case "Party":
                return { $0.party < $1.party }
            default:
                return { $0.name < $1.name }
            }
        }
    )
    
    enum CatalogTab {
        case bills
        case legislators
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterHeader
                tabSelector
                catalogList
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var searchAndFilterHeader: some View {
        VStack(spacing: 16) {
            Text("Catalog")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            TextField("Search", text: selectedTab == .bills ? $billFilterManager.searchText : $legislatorFilterManager.searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            
            if selectedTab == .bills {
                BillFilteredList(filterManager: billFilterManager)
            } else {
                LegislatorFilteredList(filterManager: legislatorFilterManager)
            }
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
    
    private var tabSelector: some View {
        Picker("Catalog", selection: $selectedTab) {
            Text("Bills").tag(CatalogTab.bills)
            Text("Legislators").tag(CatalogTab.legislators)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    struct CustomNavigationLinkStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.primary) // Use primary color instead of blue
        }
    }
    
    private var catalogList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if selectedTab == .bills {
                    ForEach(filteredBills, id: \.id) { bill in
                        BillRow(bill: bill)
                        Divider()
                    }
                } else {
                    ForEach(filteredLegislators, id: \.id) { legislator in
                        NavigationLink(destination: LegislatorDetailPage(legislator: legislator)) {
                            LegislatorRow(legislator: legislator)
                        }
                        .buttonStyle(CustomNavigationLinkStyle())
                        Divider()
                    }
                }
            }
        }
    }
    
    private var filteredBills: [Bill] {
        billFilterManager.filter(votingManager.bills) { bill, filters, searchText in
            let matchesSearch = searchText.isEmpty || bill.title.lowercased().contains(searchText.lowercased())
            let matchesFilters = filters.isEmpty || filters.allSatisfy { key, values in
                switch key {
                case "tags": return !Set(bill.tags).isDisjoint(with: values)
                case "sessions": return values.contains(bill.session)
                case "bodies": return values.contains(bill.body)
                default: return true
                }
            }
            return matchesSearch && matchesFilters
        }
    }
    
    private var filteredLegislators: [Legislator] {
        legislatorFilterManager.filter(sampleLegislators) { legislator, filters, searchText in
            let matchesSearch = searchText.isEmpty || legislator.name.lowercased().contains(searchText.lowercased())
            let matchesFilters = filters.isEmpty || filters.allSatisfy { key, values in
                switch key {
                case "parties": return values.contains(legislator.party)
                case "states": return values.contains(legislator.state)
                case "chambers": return values.contains(legislator.chamber)
                default: return true
                }
            }
            return matchesSearch && matchesFilters
        }
    }
}


// MARK: - Common Components

struct HeaderView<Content: View>: View {
    let backgroundColor: Color
    let content: Content
    
    init(backgroundColor: Color = .oldGloryBlue, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            content
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct TableRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
        }
        .padding()
        .background(Color.white)
    }
}

struct TableHeader: View {
    let headers: [String]
    
    var body: some View {
        HStack {
            ForEach(headers, id: \.self) { header in
                Spacer()
                Text(header)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2))
    }
}

// MARK: - Bills

struct BillFilteredList: View {
    @ObservedObject var filterManager: FilterManager<Bill>
    
    let sortOptions = ["Updated", "Title", "Popularity"]
    
    var filterCategories: [FilterCategory<Bill>] {
        [
            FilterCategory(name: "Tags", key: "tags", values: Array(Set(sampleBills.flatMap { $0.tags }))),
            FilterCategory(name: "Sessions", key: "sessions", values: Array(Set(sampleBills.map { $0.session }))),
            FilterCategory(name: "Bodies", key: "bodies", values: Array(Set(sampleBills.map { $0.body })))
        ]
    }
    
    var body: some View {
        FilteredList(filterManager: filterManager, sortOptions: sortOptions, filterCategories: filterCategories)
    }
}

struct BillRow: View {
    let bill: Bill
    
    var body: some View {
        NavigationLink(destination: BillDetailPage(bill: bill)) {
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
        .background(Color.white)
        Divider()
    }
}

struct BillDetailPage: View {
    @EnvironmentObject var votingManager: VotingManager
    @State var bill: Bill
    @State private var showingAddComment = false
    
    var body: some View {
        VStack(spacing: 0) {
            billHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    citizenOpinionSection
                    votingSection
                    citizensBriefingSection
                    commentSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .sheet(isPresented: $showingAddComment) {
            AddCommentModal(bill: $bill, parentId: nil)
        }
    }
    
    private var billHeader: some View {
        HeaderView {
            Text(bill.state).font(.title)
            Text(bill.title).font(.title)
            Text("Body: \(bill.body)").font(.subheadline)
            Text("Session: \(bill.session)").font(.subheadline)
            tagScrollView
        }
    }
    
    private var tagScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Text("Tags:").font(.subheadline)
                ForEach(bill.tags, id: \.self) { TagChip(title: $0) }
            }
        }
    }
    
    private var citizenOpinionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Citizens Opinion").font(.headline)
            HStack {
                Text("Yes: \(bill.yesVotes)")
                Spacer()
                Text("No: \(bill.noVotes)")
            }
            VoteDistributionBar(yesVotes: bill.yesVotes, noVotes: bill.noVotes)
        }
    }
    
    private var votingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let userVote = bill.userVote {
                Text("You voted: \(userVote == .yes ? "Yes" : "No").")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Do you approve of this bill?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VoteButton(title: "Vote Yes", color: .fruitSaladGreen, action: { vote(.yes) }, isSelected: bill.userVote == .yes)
                VoteButton(title: "Vote No", color: .oldGloryRed, action: { vote(.no) }, isSelected: bill.userVote == .no)
            }
        }
    }
    
    private func vote(_ vote: Vote) {
        votingManager.vote(for: bill, vote: vote)
        updateBillState()
    }
    
    private var citizensBriefingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Citizens Briefing").font(.headline).fontWeight(.bold)
                Spacer()
                Button("See Full text") {
                    // TODO - Add this functionality
                }
            }
            Text("This summary is generated by AI and may contain inaccuracies. Please refer to the full text for official information, and contact us to report any errors.")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(bill.briefing).font(.body)
        }
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Comments").font(.headline)
                Spacer()
                Button("Add Comment") { showingAddComment = true }
            }
            
            if bill.comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                CommentsList(comments: bill.comments, bill: $bill, parentId: nil, level: 0)
            }
        }
    }
    
    private func updateBillState() {
        if let updatedBill = votingManager.bills.first(where: { $0.id == bill.id }) {
            bill = updatedBill
        }
    }
}

// MARK: - Legislator Components

struct LegislatorFilteredList: View {
    @ObservedObject var filterManager: FilterManager<Legislator>
    
    let sortOptions = ["Name", "State", "Party"]
    
    var filterCategories: [FilterCategory<Legislator>] {
        [
            FilterCategory(name: "Parties", key: "parties", values: Array(Set(sampleLegislators.map { $0.party }))),
            FilterCategory(name: "States", key: "states", values: Array(Set(sampleLegislators.map { $0.state }))),
            FilterCategory(name: "Chambers", key: "chambers", values: Array(Set(sampleLegislators.map { $0.chamber })))
        ]
    }
    
    var body: some View {
        FilteredList(filterManager: filterManager, sortOptions: sortOptions, filterCategories: filterCategories)
    }
}

struct LegislatorRow: View {
    let legislator: Legislator
    
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
                Text(legislator.name).font(.headline)
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
    @EnvironmentObject var votingManager: VotingManager
    @EnvironmentObject var userVotingRecord: UserVotingRecord
    
    var body: some View {
        VStack(spacing: 0) {
            legislatorHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScoreSection(attendanceScore: legislator.attendanceScore(),
                                 alignmentScore: legislator.alignmentScore(with: userVotingRecord.votes))
                    InfoSection("Top Issues") {
                        ForEach(legislator.topIssues, id: \.self) { Text("• \($0)") }
                    }
                    ContactInfoSection(contactInfo: legislator.contactInfo)
                    SocialMediaSection(socialMedia: legislator.socialMedia)
                    VotingRecordSection(votingRecord: legislator.votingRecord, votingManager: votingManager)
                    FundingRecordSection(fundingRecord: legislator.fundingRecord) // New section
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
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
        let attendanceScore: Double
        let alignmentScore: Double
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Attendance Score: \(String(format: "%.0f", attendanceScore))%").font(.headline)
                Text("Alignment Score: \(String(format: "%.0f", alignmentScore))%").font(.headline)
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
        let votingRecord: [VotingRecord]
        let votingManager: VotingManager
        
        var body: some View {
            InfoSection("Recent Voting Record") {
                VStack(spacing: 0) {
                    TableHeader(headers: ["Bill", "Vote", "Date"])
                    
                    ForEach(votingRecord.prefix(5)) { record in
                        TableRow {
                            if let bill = votingManager.bills.first(where: { $0.id == record.billId }) {
                                Text(bill.title)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Unknown Bill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text(record.vote.rawValue)
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
                
                if votingRecord.count > 5 {
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

struct VoteDistributionBar: View {
    let yesVotes: Int
    let noVotes: Int
    
    private var totalVotes: Int {
        yesVotes + noVotes
    }
    
    private var yesPercentage: CGFloat {
        totalVotes > 0 ? CGFloat(yesVotes) / CGFloat(totalVotes) : 0
    }
    
    private func formatPercentage(_ value: CGFloat) -> String {
        String(format: "%.1f%%", value * 100)
    }
    
    var body: some View {
        GeometryReader { geometry in
            if totalVotes == 0 {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    Text("No citizen votes yet")
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                }
            } else {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.fruitSaladGreen)
                        .frame(width: geometry.size.width * yesPercentage)
                        .overlay(
                            HStack {
                                Spacer()
                                Text(formatPercentage(yesPercentage))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                Spacer()
                            }, alignment: .leading
                        )
                    
                    Rectangle()
                        .fill(Color.oldGloryRed)
                        .frame(width: geometry.size.width * (1 - yesPercentage))
                        .overlay(
                            HStack {
                                Spacer()
                                Text(formatPercentage(1 - yesPercentage))
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 4)
                                Spacer()
                            }, alignment: .trailing
                        )
                }
            }
        }
        .frame(height: 30)
        .cornerRadius(15)
    }
}

// MARK: - UserSettings

struct UserSettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                List {
                    Section(header: Text("Account")) {
                        NavigationLink("Edit Profile", destination: EditProfileView())
                        NavigationLink("Select Preferred Topics", destination: TopicSelectorView(selectedTopics: $settingsManager.preferredTopics))
                        NavigationLink("Change Password", destination: ChangePasswordView())
                        NavigationLink("Privacy Settings", destination: PrivacySettingsView())
                        Button("Log Out") {
                            // Implement log out functionality
                        }
                        .foregroundColor(.oldGloryRed)
                    }
                    
                    Section(header: Text("Notifications")) {
                        CustomToggle(title: "Push Notifications", isOn: $settingsManager.pushNotificationsEnabled)
                        CustomToggle(title: "Email Notifications", isOn: $settingsManager.emailNotificationsEnabled)
                    }
                    
                    Section(header: Text("Support")) {
                        NavigationLink("Help Center", destination: HelpCenterView())
                        NavigationLink("About", destination: AboutView())
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarHidden(true)
        }
    }
    
    struct CustomToggle: View {
        let title: String
        @Binding var isOn: Bool
        
        var body: some View {
            Toggle(isOn: $isOn) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .toggleStyle(SwitchToggleStyle(tint: .oldGloryBlue))
        }
    }
    
    struct PrivacySettingsView: View {
        var body: some View {
            Text("Privacy Settings")
            // Implement privacy settings
        }
    }
    
    struct HelpCenterView: View {
        var body: some View {
            Text("Help Center")
            // Implement help center
        }
    }
    
    struct AboutView: View {
        var body: some View {
            Text("About")
            // Implement about section
        }
    }
    
    struct EditProfileView: View {
        var body: some View {
            Text("Edit Profile")
            // Implement profile editing
        }
    }
    
    struct ChangePasswordView: View {
        var body: some View {
            Text("Change Password")
            // Implement
        }
    }
    
    struct TopicSelectorView: View {
        @Binding var selectedTopics: Set<String>
        
        let allTopics = ["Education", "Healthcare", "Environment", "Economy", "Foreign Policy"]
        
        var body: some View {
            List {
                ForEach(allTopics, id: \.self) { topic in
                    Button(action: {
                        if selectedTopics.contains(topic) {
                            selectedTopics.remove(topic)
                        } else {
                            selectedTopics.insert(topic)
                        }
                    }) {
                        HStack {
                            Text(topic)
                            Spacer()
                            if selectedTopics.contains(topic) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Topics")
        }
    }
}

// MARK: - General

struct FilteredList<T>: View {
    @ObservedObject var filterManager: FilterManager<T>
    let sortOptions: [String]
    let filterCategories: [FilterCategory<T>]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                filterMenu
                Spacer()
                sortMenu
            }
            
            if !filterManager.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(filterManager.filters.keys.sorted(), id: \.self) { key in
                            ForEach(Array(filterManager.filters[key] ?? []), id: \.self) { value in
                                FilterChip(title: "\(key): \(value)") {
                                    filterManager.removeFilter(value, forKey: key)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var filterMenu: some View {
        Menu {
            ForEach(filterCategories, id: \.key) { category in
                Menu(category.name) {
                    ForEach(category.values, id: \.self) { value in
                        Button(action: {
                            filterManager.addFilter(value, forKey: category.key)
                        }) {
                            HStack {
                                Text(value)
                                if filterManager.filters[category.key]?.contains(value) == true {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease")
                Text("Filter\(!filterManager.isEmpty ? " (\(filterManager.count))" : "")")
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.oldGloryRed)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(sortOptions, id: \.self) { option in
                Button(action: {
                    if filterManager.sortOption == option {
                        filterManager.toggleSortOrder()
                    } else {
                        filterManager.sortOption = option
                        filterManager.sortOrder = .ascending
                    }
                }) {
                    HStack {
                        Text(option)
                        if filterManager.sortOption == option {
                            Image(systemName: filterManager.sortOrder == .ascending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text("Sort: \(filterManager.sortOption)")
                Image(systemName: filterManager.sortOrder == .ascending ? "chevron.up" : "chevron.down")
            }
            .foregroundColor(.oldGloryRed)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}


struct ContentView: View {
    @StateObject private var userVotingRecord = UserVotingRecord()
    @StateObject private var votingManager: VotingManager
    
    init() {
        let userVotingRecord = UserVotingRecord()
        self._votingManager = StateObject(wrappedValue: VotingManager(bills: sampleBills, userVotingRecord: userVotingRecord))
        self._userVotingRecord = StateObject(wrappedValue: userVotingRecord)
    }
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Feed", systemImage: "bell") }
            CatalogPage()
                .tabItem { Label("Catalog", systemImage: "list.bullet") }
            UserSettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .environmentObject(votingManager)
        .environmentObject(userVotingRecord)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
