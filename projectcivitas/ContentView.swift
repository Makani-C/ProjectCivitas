import SwiftUI

// MARK: - StartPage

struct StartPage: View {
    @Binding var isUserLoggedIn: Bool
    
    @State private var showSignUp = false
    @State private var showLogin = false
    
    var body: some View {
        ZStack {
            Color.oldGloryBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "flag.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                
                Text("Welcome to Civitas")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your platform for engaging with democracy and making your voice heard.")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: { showSignUp = true }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.oldGloryBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { isUserLoggedIn = true; showLogin = true }) {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.oldGloryRed)
                            .cornerRadius(10)
                        
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(isUserLoggedIn: $isUserLoggedIn)
        }
        .sheet(isPresented: $showLogin) {
            Text("Login View")
        }
    }
    
    struct SignUpView: View {
        @Environment(\.presentationMode) var presentationMode
        @Binding var isUserLoggedIn: Bool
        
        @State private var email = ""
        @State private var password = ""
        @State private var confirmPassword = ""
        @State private var fullName = ""
        @State private var errorMessage = ""
        @State private var isLoading = false
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("Full Name", text: $fullName)
                            .autocapitalization(.words)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    Section(header: Text("Security")) {
                        SecureField("Password", text: $password)
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.oldGloryRed)
                        }
                    }
                    
                    Section {
                        Button(action: signUp) {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Up")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(isLoading || !isFormValid)
                    }
                    
                    
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption)
                        .foregroundColor(.oldGloryBlue.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .navigationTitle("Create Account")
                .navigationBarItems(leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        
        private var isFormValid: Bool {
            !fullName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
        }
        
        private func signUp() {
            isLoading = true
            errorMessage = ""
            
            // Simulate a successful sign up request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
                isUserLoggedIn = true
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Feed

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
    @EnvironmentObject var dataManager: DataManager
    @State private var feedItems: [FeedItem] = []
    @State private var selectedTags: Set<String> = []
    
    private func generateFeedItems() {
        // TODO - move feed generation to API
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
    
    var filteredFeedItems: [FeedItem] {
        if selectedTags.isEmpty {
            return feedItems
        } else {
            return feedItems.filter { item in
                !selectedTags.isDisjoint(with: Set(item.tags))
            }
        }
    }
    
    var allTags: [String] {
        Array(Set(feedItems.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView {
                    Text("Feed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Divider().background(.white).bold()
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
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredFeedItems) { item in
                            FeedItemView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            generateFeedItems()
        }
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
    @EnvironmentObject var votingManager: VoteManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var userVotingRecord: UserVotingRecord
    
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

// MARK: - Catalog

struct CatalogPage: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var votingManager: VoteManager
    @EnvironmentObject var dataManager: DataManager
    
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
            Divider().background(.white).bold()
            
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
        billFilterManager.filter(dataManager.bills) { bill, filters, searchText in
            let matchesSearch = searchText.isEmpty || bill.title.lowercased().contains(searchText.lowercased())
            let matchesFilters = filters.isEmpty || filters.allSatisfy { key, values in
                switch key {
                case "tags": return !Set(bill.tags).isDisjoint(with: values)
                case "sessions": return values.contains(bill.session)
                case "bodies": return values.contains(bill.body)
                case "followed": return values.contains("true") ? settingsManager.isFollowing(bill) : true
                default: return true
                }
            }
            return matchesSearch && matchesFilters
        }
    }
    
    private var filteredLegislators: [Legislator] {
        legislatorFilterManager.filter(dataManager.legislators) { legislator, filters, searchText in
            let matchesSearch = searchText.isEmpty || legislator.name.lowercased().contains(searchText.lowercased())
            let matchesFilters = filters.isEmpty || filters.allSatisfy { key, values in
                switch key {
                case "parties": return values.contains(legislator.party)
                case "states": return values.contains(legislator.state)
                case "chambers": return values.contains(legislator.chamber)
                case "followed": return values.contains("true") ? settingsManager.isFollowing(legislator) : true
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
                .foregroundColor(.oldGloryRed)
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

// MARK: - Legislator Components

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
    @EnvironmentObject var userVotingRecord: UserVotingRecord
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 0) {
            legislatorHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScoreSection(
                        attendanceScore: legislator.attendanceScore(votingRecords: dataManager.votingRecords),
                        alignmentScore: legislator.alignmentScore(with: userVotingRecord.votes, votingRecords: dataManager.votingRecords)
                    )
                    InfoSection("Top Issues") {
                        ForEach(legislator.topIssues, id: \.self) { Text("• \($0)") }
                    }
                    ContactInfoSection(contactInfo: legislator.contactInfo)
                    SocialMediaSection(socialMedia: legislator.socialMedia)
                    VotingRecordSection(votingRecord: legislator.getVotingRecord(allVotingRecords: dataManager.votingRecords), votingManager: votingManager)
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
        let votingRecord: [VotingRecord]
        let votingManager: VoteManager
        
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


struct CelebrateVoteView: View {
    let vote: Vote
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissAnimation()
                }
            
            VStack {
                Image(systemName: vote == .yes ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 100)
                    .foregroundColor(vote == .yes ? .fruitSaladGreen : .oldGloryRed)
                
                Text("Voted!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                    .shadow(color: .black.opacity(0.6), radius: 2, x: 1, y: 1)
            }
            .padding(30)
            .background(
                ZStack {
                    Color.white
                    PatrioticBackground()
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.oldGloryBlue, lineWidth: 4)
            )
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                scale = 1.0
                rotation = 360
                opacity = 1
            }
        }
    }
    
    private func dismissAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.5
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
    
    struct PatrioticBackground: View {
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Red stripes
                    ForEach(0..<5) { i in
                        Rectangle()
                            .fill(Color.oldGloryRed)
                            .frame(height: geometry.size.height / 13)
                            .offset(y: CGFloat(i * 2) * geometry.size.height / 13)
                    }
                    
                    // Blue canton
                    Rectangle()
                        .fill(Color.oldGloryBlue)
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 7/13)
                        .position(x: geometry.size.width * 0.2, y: geometry.size.height * 7/26)
                    
                    // Stars
                    ForEach(0..<5) { row in
                        ForEach(0..<4) { col in
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                                .position(
                                    x: geometry.size.width * (0.05 + Double(col) * 0.1),
                                    y: geometry.size.height * (0.05 + Double(row) * 0.1)
                                )
                        }
                    }
                }
            }
            .opacity(0.2) // Make the background subtle
        }
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
    @StateObject private var votingManager: VoteManager
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var dataManager: DataManager
    @State private var isUserLoggedIn = false
    
    init() {
        let dataSource = MockDataSource()
        let dataManager = DataManager(dataSource: dataSource)
        self._dataManager = StateObject(wrappedValue: dataManager)
        self._votingManager = StateObject(wrappedValue: VoteManager(dataManager: dataManager, userVotingRecord: UserVotingRecord()))
    }
    
    var body: some View {
        Group {
            if isUserLoggedIn {
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
                .environmentObject(settingsManager)
                .environmentObject(dataManager)
            } else {
                StartPage(isUserLoggedIn: $isUserLoggedIn)
            }
        }.task {
            await dataManager.loadData()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
