import SwiftUI

// MARK: - Bill Views

import SwiftUI

// MARK: - Bill Views

struct BillListPage: View {
    @EnvironmentObject var votingManager: VotingManager
    @StateObject private var filterManager = FilterManager<Bill>(
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterHeader
                billList
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
            
            TextField("Search", text: $filterManager.searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            
            BillFilteredList(filterManager: filterManager)
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
    
    private var billList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(filteredBills, id: \.id) { bill in
                    BillRow(bill: bill)
                }
            }
        }
    }
    
    private var filteredBills: [Bill] {
        filterManager.filter(votingManager.bills) { bill, filters, searchText in
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
}

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

struct CommentRow: View {
    let comment: Comment
    let level: Int
    @Binding var bill: Bill
    @State private var isReplying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.user).font(.headline)
                Spacer()
                Text(comment.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
            
            HStack {
                Button("Reply") {
                    isReplying = true
                }
                .font(.caption)
                .foregroundColor(.blue)
                Spacer()
            }
            
            if !comment.replies.isEmpty {
                CommentsList(comments: comment.replies, bill: $bill, parentId: comment.id, level: level + 1)
            }
        }
        .padding(.leading, CGFloat(level) * 20)
        .padding(.vertical, 8)
        .sheet(isPresented: $isReplying) {
            AddCommentModal(bill: $bill, parentId: comment.id)
        }
    }
}

struct CommentsList: View {
    let comments: [Comment]
    @Binding var bill: Bill
    let parentId: UUID?
    let level: Int
    
    var body: some View {
        ForEach(comments) { comment in
            CommentRow(comment: comment, level: level, bill: $bill)
        }
    }
}

struct AddCommentModal: View {
    @Binding var bill: Bill
    @State private var commentText = ""
    @Environment(\.presentationMode) var presentationMode
    let parentId: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Comment")) {
                    TextEditor(text: $commentText)
                        .frame(height: 100)
                }
                
                Button("Submit Comment") {
                    submitComment()
                }
                .disabled(commentText.isEmpty)
            }
            .navigationTitle(parentId == nil ? "Add Comment" : "Add Reply")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func submitComment() {
        let newComment = Comment(user: "CurrentUser", text: commentText, timestamp: Date(), parentId: parentId)
        
        if let parentId = parentId {
            addReply(newComment, to: parentId)
        } else {
            bill.comments.append(newComment)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func addReply(_ reply: Comment, to parentId: UUID) {
        if let index = bill.comments.firstIndex(where: { $0.id == parentId }) {
            bill.comments[index].replies.append(reply)
        } else {
            for i in 0..<bill.comments.count {
                if addReplyRecursively(reply, to: parentId, in: &bill.comments[i]) {
                    break
                }
            }
        }
    }
    
    private func addReplyRecursively(_ reply: Comment, to parentId: UUID, in comment: inout Comment) -> Bool {
        if comment.id == parentId {
            comment.replies.append(reply)
            return true
        }
        
        for i in 0..<comment.replies.count {
            if addReplyRecursively(reply, to: parentId, in: &comment.replies[i]) {
                return true
            }
        }
        
        return false
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

struct BillDetailPage: View {
    @EnvironmentObject var votingManager: VotingManager
    @State var bill: Bill
    @State private var showingAddComment = false
    
    var body: some View {
        VStack(spacing: 0) {
            billHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Citizens Opinion")
                        .font(.headline)
                    HStack {
                        Text("Yes: \(bill.yesVotes)")
                        Spacer()
                        Text("No: \(bill.noVotes)")
                    }
                    VoteDistributionBar(yesVotes: bill.yesVotes, noVotes: bill.noVotes)
                    
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
                        VoteButton(
                            title: "Vote Yes",
                            color: .fruitSaladGreen,
                            action: {
                                votingManager.vote(for: bill, vote: .yes)
                                updateBillState()
                            },
                            isSelected: bill.userVote == .yes
                        )
                        
                        VoteButton(
                            title: "Vote No",
                            color: .oldGloryRed,
                            action: {
                                votingManager.vote(for: bill, vote: .no)
                                updateBillState()
                            },
                            isSelected: bill.userVote == .no
                        )
                    }
                    Divider()
                    HStack {
                        Text("Citizens Briefing")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Button("See Full text") {
                            // TODO - Add this functionality
                        }
                    }
                    Text("This summary is generated by AI and may contain inaccuracies. Please refer to the full text for official information, and contact us to report any errors.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(bill.briefing)
                        .font(.body)
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
    
    private func updateBillState() {
        if let updatedBill = votingManager.bills.first(where: { $0.id == bill.id }) {
            bill = updatedBill
        }
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Comments")
                    .font(.headline)
                Spacer()
                Button("Add Comment") {
                    showingAddComment = true
                }
            }
            
            if bill.comments.isEmpty {
                Text("No comments yet. Be the first to comment!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                CommentsList(comments: bill.comments, bill: $bill, parentId: nil, level: 0)
            }
        }
        .sheet(isPresented: $showingAddComment) {
            AddCommentModal(bill: $bill, parentId: nil)
        }
    }
    
    private var billHeader: some View {
        VStack(spacing: 8) {
            Text(bill.state)
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(bill.title)
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Body: \(bill.body)")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Session: \(bill.session)")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Text("Tags:")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    ForEach(bill.tags, id: \.self) { tag in
                        TagChip(title: tag)
                    }
                }
            }
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
}

// MARK: - Legislator Views

struct LegislatorListPage: View {
    let legislators: [Legislator]
    @StateObject private var filterManager = FilterManager<Legislator>(
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterHeader
                legislatorList
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var searchAndFilterHeader: some View {
        VStack(spacing: 16) {
            Text("Legislators")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            TextField("Search", text: $filterManager.searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            
            LegislatorFilteredList(filterManager: filterManager)
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
    
    private var legislatorList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(filteredLegislators, id: \.id) { legislator in
                    NavigationLink(destination: LegislatorDetailPage(legislator: legislator)) {
                        LegislatorRow(legislator: legislator)
                    }
                    Divider()
                }
            }
        }
    }
    
    private var filteredLegislators: [Legislator] {
        filterManager.filter(legislators) { legislator, filters, searchText in
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
                Text(legislator.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(legislator.party) - \(legislator.state)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(legislator.chamber)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
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
                    Text("Alignment Score: \(String(format: "%.1f", legislator.alignmentScore(with: userVotingRecord.votes)))%")
                        .font(.headline)
                    infoSection(title: "Top Issues") {
                        ForEach(legislator.topIssues, id: \.self) { issue in
                            Text("• \(issue)")
                        }
                    }
                    
                    infoSection(title: "Contact Information") {
                        Text("Email: \(legislator.contactInfo.email)")
                        Text("Phone: \(legislator.contactInfo.phone)")
                        Text("Office: \(legislator.contactInfo.office)")
                    }
                    
                    infoSection(title: "Social Media") {
                        if let twitter = legislator.socialMedia.twitter {
                            Text("Twitter: @\(twitter)")
                        }
                        if let facebook = legislator.socialMedia.facebook {
                            Text("Facebook: \(facebook)")
                        }
                        if let instagram = legislator.socialMedia.instagram {
                            Text("Instagram: @\(instagram)")
                        }
                    }
                    
                    infoSection(title: "Recent Voting Record") {
                        ForEach(legislator.votingRecord.prefix(5)) { record in
                            VStack(alignment: .leading, spacing: 4) {
                                if let bill = votingManager.bills.first(where: { $0.id == record.billId }) {
                                    Text(bill.title)
                                        .font(.subheadline)
                                } else {
                                    Text("Unknown Bill")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                HStack {
                                    Text("Vote: \(record.vote.rawValue)")
                                    Spacer()
                                    Text(record.date, formatter: itemFormatter)
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
    
    
    private var legislatorHeader: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: legislator.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .clipShape(Circle())
            
            Text(legislator.name)
                .font(.title)
                .foregroundColor(.white)
            
            Text("\(legislator.party) - \(legislator.state)")
                .font(.headline)
                .foregroundColor(.white)
            
            if let district = legislator.district {
                Text("District: \(district)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Text(legislator.chamber)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
    
    private func infoSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            content()
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}


struct UserSettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingEditProfile = false
    @State private var showingTopicSelector = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Button("Edit Profile") {
                        showingEditProfile = true
                    }
                    Button("Change Password") {
                        // Implement password change functionality
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $settingsManager.pushNotificationsEnabled)
                    Toggle("Email Notifications", isOn: $settingsManager.emailNotificationsEnabled)
                }
                
                Section(header: Text("Content Preferences")) {
                    Button("Select Preferred Topics") {
                        showingTopicSelector = true
                    }
                }
                
                Section(header: Text("Privacy")) {
                    NavigationLink("Privacy Settings") {
                        PrivacySettingsView()
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink("Help Center") {
                        HelpCenterView()
                    }
                    NavigationLink("About") {
                        AboutView()
                    }
                }
                
                Section {
                    Button("Log Out") {
                        // Implement log out functionality
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingTopicSelector) {
            TopicSelectorView(selectedTopics: $settingsManager.preferredTopics)
        }
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

struct FilterCategory<T> {
    let name: String
    let key: String
    let values: [String]
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
            BillListPage()
                .tabItem { Label("Bills", systemImage: "doc.text") }
            LegislatorListPage(legislators: sampleLegislators)
                .tabItem { Label("Legislators", systemImage: "person.2") }
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
