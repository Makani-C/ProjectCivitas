import SwiftUI

// MARK: - Bill Views

struct BillListPage: View {
    @EnvironmentObject var votingManager: VotingManager
    @State private var searchText = ""
    @State private var sortOption = "Updated (Desc)"
    @State private var activeFilters = 2
    @State private var filters = Filters()
    
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
            
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            
            BillFilteredList(sortOption: $sortOption, filters: $filters)
        }
        .padding()
        .background(Color.oldGloryBlue)
    }
    
    private var filteredBills: [Bill] {
        sampleBills.filter { bill in
            (filters.tags.isEmpty || !Set(bill.tags).isDisjoint(with: filters.tags)) &&
            (filters.sessions.isEmpty || filters.sessions.contains(bill.session)) &&
            (filters.bodies.isEmpty || filters.bodies.contains(bill.body))
        }
    }
    
    private var billList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(votingManager.bills, id: \.id) { bill in
                    BillRow(bill: bill)
                }
            }
        }
    }
}

struct BillFilteredList: View {
    @Binding var sortOption: String
    @Binding var filters: Filters
    
    let sortOptions = ["Updated (Desc)", "Updated (Asc)", "Bill Number", "Popularity"]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                filterMenu
                Spacer()
                sortMenu
            }
            
            if !filters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(filters.tags), id: \.self) { tag in
                            FilterChip(title: "Tag: \(tag)") {
                                filters.tags.remove(tag)
                            }
                        }
                        ForEach(Array(filters.sessions), id: \.self) { session in
                            FilterChip(title: "Session: \(session)") {
                                filters.sessions.remove(session)
                            }
                        }
                        ForEach(Array(filters.bodies), id: \.self) { body in
                            FilterChip(title: "Body: \(body)") {
                                filters.bodies.remove(body)
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
            Menu("Tags") {
                ForEach(Array(Set(sampleBills.flatMap { $0.tags })), id: \.self) { tag in
                    Button(action: {
                        if filters.tags.contains(tag) {
                            filters.tags.remove(tag)
                        } else {
                            filters.tags.insert(tag)
                        }
                    }) {
                        HStack {
                            Text(tag)
                            if filters.tags.contains(tag) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Menu("Sessions") {
                ForEach(Array(Set(sampleBills.map { $0.session })), id: \.self) { session in
                    Button(action: {
                        if filters.sessions.contains(session) {
                            filters.sessions.remove(session)
                        } else {
                            filters.sessions.insert(session)
                        }
                    }) {
                        HStack {
                            Text(session)
                            if filters.sessions.contains(session) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            
            Menu("Bodies") {
                ForEach(Array(Set(sampleBills.map { $0.body })), id: \.self) { body in
                    Button(action: {
                        if filters.bodies.contains(body) {
                            filters.bodies.remove(body)
                        } else {
                            filters.bodies.insert(body)
                        }
                    }) {
                        HStack {
                            Text(body)
                            if filters.bodies.contains(body) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease")
                Text("Filter\(!filters.isEmpty ? " (\(filters.count))" : "")")
                Image(systemName: "chevron.down")
            }.foregroundColor(.oldGloryRed)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white)
                .cornerRadius(8)
        }
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(sortOptions, id: \.self) { option in
                Button(action: { sortOption = option }) {
                    HStack {
                        Text(option)
                        if sortOption == option { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack {
                Text("Sort: \(sortOption)")
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.oldGloryRed)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
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

struct TagChip: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.footnote)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

// MARK: - Legislator Views

struct LegislatorListPage: View {
    let legislators: [Legislator]
    @State private var searchText = ""
    @State private var sortOption = "Name (A-Z)"
    @State private var filters = LegislatorFilters()
    
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
            
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            
            LegislatorFilteredList(sortOption: $sortOption, filters: $filters)
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
        legislators.filter { legislator in
            (searchText.isEmpty || legislator.name.lowercased().contains(searchText.lowercased())) &&
            (filters.parties.isEmpty || filters.parties.contains(legislator.party)) &&
            (filters.states.isEmpty || filters.states.contains(legislator.state)) &&
            (filters.chambers.isEmpty || filters.chambers.contains(legislator.chamber))
        }
    }
}

struct LegislatorFilteredList: View {
    @Binding var sortOption: String
    @Binding var filters: LegislatorFilters
    
    let sortOptions = ["Name (A-Z)", "Name (Z-A)", "State", "Party"]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                filterMenu
                Spacer()
                sortMenu
            }
            
            if !filters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(filters.parties), id: \.self) { party in
                            FilterChip(title: "Party: \(party)") {
                                filters.parties.remove(party)
                            }
                        }
                        ForEach(Array(filters.states), id: \.self) { state in
                            FilterChip(title: "State: \(state)") {
                                filters.states.remove(state)
                            }
                        }
                        ForEach(Array(filters.chambers), id: \.self) { chamber in
                            FilterChip(title: "Chamber: \(chamber)") {
                                filters.chambers.remove(chamber)
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
            Menu("Parties") {
                ForEach(Array(Set(sampleLegislators.map { $0.party })), id: \.self) { party in
                    Button(action: {
                        if filters.parties.contains(party) {
                            filters.parties.remove(party)
                        } else {
                            filters.parties.insert(party)
                        }
                    }) {
                        HStack {
                            Text(party)
                            if filters.parties.contains(party) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Menu("States") {
                ForEach(Array(Set(sampleLegislators.map { $0.state })), id: \.self) { state in
                    Button(action: {
                        if filters.states.contains(state) {
                            filters.states.remove(state)
                        } else {
                            filters.states.insert(state)
                        }
                    }) {
                        HStack {
                            Text(state)
                            if filters.states.contains(state) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Menu("Chambers") {
                ForEach(Array(Set(sampleLegislators.map { $0.chamber })), id: \.self) { chamber in
                    Button(action: {
                        if filters.chambers.contains(chamber) {
                            filters.chambers.remove(chamber)
                        } else {
                            filters.chambers.insert(chamber)
                        }
                    }) {
                        HStack {
                            Text(chamber)
                            if filters.chambers.contains(chamber) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease")
                Text("Filter\(!filters.isEmpty ? " (\(filters.count))" : "")")
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
                Button(action: { sortOption = option }) {
                    HStack {
                        Text(option)
                        if sortOption == option { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            HStack {
                Text("Sort: \(sortOption)")
                Image(systemName: "chevron.down")
            }
            .foregroundColor(.oldGloryRed)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
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

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(title).font(.footnote)
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.caption)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(.white.opacity(0.8))
        .foregroundColor(.blue)
        .cornerRadius(16)
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
