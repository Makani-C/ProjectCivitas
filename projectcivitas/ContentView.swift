import SwiftUI

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

// MARK: - UserSettings

struct UserSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
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
    @StateObject private var voteManager: VoteManager
    @StateObject private var settingsManager: SettingsManager
    @StateObject private var dataManager: DataManager
    
    @State private var isUserLoggedIn = false
    
    init() {
        let userId = UUID()
        
        let dataSource = MockDataSource()
        let dataManager = DataManager(dataSource: dataSource)
        let settingsManager = SettingsManager(userId: userId)
        
        self._dataManager = StateObject(wrappedValue: dataManager)
        self._settingsManager = StateObject(wrappedValue: settingsManager)
        self._voteManager = StateObject(wrappedValue: VoteManager(userId: userId, dataManager: dataManager))
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
                .environmentObject(voteManager)
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
