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
                FiltersView(showAttributes: true)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        
                        if mainViewModel.isLocationMode {
                            ForEach(mainViewModel.getCurrentLocations()) { mapLoc in
                                MapLocListItemRow(filter: mainViewModel.currentFilter, mapLoc: mapLoc)
                            }
                            .padding(.horizontal)
                        } else {
                            ForEach(mainViewModel.getCompanies(companyFilterType: mainViewModel.selectedCompanyFilter)) { company in
                                CompanyListItemRow(filter: mainViewModel.selectedCompanyFilter, company: company)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

struct CompanyListItemRow: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let filter: CompanyCityFilterType
    let company: Company
    
    var body: some View {
        HStack {
            Image(systemName: filter.icon)
                //.foregroundColor(mainViewModel.colorViewModel.getColor(for: filter, mapLoc: mapLoc))
                .frame(width: 30)
            
            Text(company.company)
                .font(.body)
            
            Spacer()
            
            switch filter {
            case .averageTotalComp:
                Text("$" + company.avgTotalCompAllLevels!.formatted())
                    .foregroundColor(.gray)
            case .numJobs:
                Text(mainViewModel.getNumDatapoints(company: company).formatted())
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            mainViewModel.selectedCompanyDetails = company.company
        }
    }
}

struct MapLocListItemRow: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let filter: MapLocFilterType
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
    let filter: MapLocFilterType
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

#Preview {
    ListContainer()
        .environmentObject(MainViewModel())
}
