//
//  CatalogView.swift
//

import SwiftUI

enum CatalogTab {
    case bills
    case legislators
}

struct CatalogPage: View {
    @StateObject private var viewModel = CatalogViewModel()
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var voteManager: VoteManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HeaderView {
                    Text("Catalog")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Divider().background(.white).bold()
                    
                    TextField("Search", text: $viewModel.searchText)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    if viewModel.selectedTab == .bills {
                        BillFilteredList(filterManager: viewModel.billFilterManager)
                    } else {
                        LegislatorFilteredList(filterManager: viewModel.legislatorFilterManager)
                    }
                }
                
                Picker("Catalog", selection: $viewModel.selectedTab) {
                    Text("Bills").tag(CatalogTab.bills)
                    Text("Legislators").tag(CatalogTab.legislators)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                catalogList
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var catalogList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if viewModel.selectedTab == .bills {
                    ForEach(viewModel.filteredBills(dataManager: dataManager, settingsManager: settingsManager), id: \.id) { bill in
                        BillRow(bill: bill)
                        Divider()
                    }
                } else {
                    ForEach(viewModel.filteredLegislators(dataManager: dataManager, settingsManager: settingsManager), id: \.id) { legislator in
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
}

class CatalogViewModel: ObservableObject {
    @Published var selectedTab: CatalogTab = .bills
    @Published var searchText: String = ""
    
    @Published var billFilterManager: FilterManager<Bill>
    @Published var legislatorFilterManager: FilterManager<Legislator>
    
    init() {
        self.billFilterManager = FilterManager<Bill>(
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
        
        self.legislatorFilterManager = FilterManager<Legislator>(
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
    }
    
    func filteredBills(dataManager: DataManager, settingsManager: SettingsManager) -> [Bill] {
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
    
    func filteredLegislators(dataManager: DataManager, settingsManager: SettingsManager) -> [Legislator] {
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
