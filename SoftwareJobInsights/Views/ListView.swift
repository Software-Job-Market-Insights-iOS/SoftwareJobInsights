import SwiftUI

struct ListItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
}

struct ListContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var isAggregateMode = false
    
    var topFiveCompanies: [String] {
        Array(mainViewModel.filteredCompanyNames.prefix(5))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("View Mode", selection: $mainViewModel.isCompanyMode) {
                    Text("City").tag(false)
                    Text("Company").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if mainViewModel.isCompanyMode {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Selected Company:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(mainViewModel.selectedCompany)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        // Search Field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search companies...", text: $mainViewModel.companySearchQuery)
                                .autocorrectionDisabled()
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        if !mainViewModel.companySearchQuery.isEmpty {
                            VStack(spacing: 2) {
                                ForEach(topFiveCompanies, id: \.self) { companyName in
                                    Button(action: {
                                        mainViewModel.selectedCompany = companyName
                                        mainViewModel.companySearchQuery = ""
                                    }) {
                                        HStack {
                                            Text(companyName)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Color.gray.opacity(0.05))
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }

                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(mainViewModel.getFilterTypes(), id: \.self) { filter in
                            FilterButton(
                                filter: filter,
                                isSelected: mainViewModel.isCurrentFilter(filter),
                                action: { mainViewModel.currentFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(mainViewModel.getCurrentLocations()) { mapLoc in
                            ListItemRow(filter: mainViewModel.currentFilter, mapLoc: mapLoc)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("List")
        }
    }
}

struct ListItemRow: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let filter: FilterType
    let mapLoc: MapLocation
    
    var body: some View {
        HStack {
            Image(systemName: filter.icon)
                .foregroundColor(mainViewModel.colorViewModel.getColor(for: filter, mapLoc: mapLoc))
                .frame(width: 30)
            
            Text(mapLoc.name)
                .font(.body)
            
            Spacer()
            
            Text(mainViewModel.getFormattedValue(for: filter, from: mapLoc))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            mainViewModel.selectedLocation = mapLoc
        }
    }
}

struct FilterButton: View {
    let filter: FilterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct DetailView: View {
    let item: ListItem
    
    var body: some View {
        VStack {
            Text(item.title)
            Text(item.value)
        }
        .navigationTitle("Details")
    }
}

// Preview
#Preview {
    ListContainer()
        .environmentObject(MainViewModel())
}
