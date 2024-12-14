import SwiftUI

struct ListContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showFilters = false
    @State private var selectedCity: City?
    @State private var selectedCompanyCity: CompanyCity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Filter Toggle Button
            Button(action: { showFilters.toggle() }) {
                Label(showFilters ? "Hide Filters" : "Show Filters",
                      systemImage: showFilters ? "chevron.up" : "chevron.down")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            // Mode Toggle Button
            HStack {
                Spacer()
                Button(action: { mainViewModel.toggleMode() }) {
                    Label(mainViewModel.isCompanyMode ? mainViewModel.selectedCompany : "City Mode",
                          systemImage: mainViewModel.isCompanyMode ? "building.2" : "map")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
            
            // Filters Section
            if showFilters {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Filter By:")
                        .font(.headline)
                    
                    // Filter Types
                    ForEach(mainViewModel.getFilterTypes()) { filter in
                        Button(action: { mainViewModel.setFilter(filter) }) {
                            HStack {
                                Text(filter.title)
                                if mainViewModel.isCurrentFilter(filter) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Company or City Specific Filters
                    if mainViewModel.isCompanyMode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Search Companies:")
                                .font(.headline)
                            
                            TextField("Enter company name...", text: $mainViewModel.companySearchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocorrectionDisabled()
                            
                            ScrollView {
                                LazyVStack(alignment: .leading) {
                                    ForEach(mainViewModel.filteredCompanyNames, id: \.self) { companyName in
                                        Button(action: { mainViewModel.selectedCompany = companyName }) {
                                            HStack {
                                                Text(companyName)
                                                Spacer()
                                                if mainViewModel.selectedCompany == companyName {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    } else {
                        Text("Number of Cities: \(mainViewModel.numOfCitiesCity)")
                            .font(.headline)
                        Slider(value: .init(
                            get: { Double(mainViewModel.numOfCitiesCity) },
                            set: { newValue in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    mainViewModel.numOfCitiesCity = Int(newValue)
                                }
                            }
                        ), in: 5...30, step: 5)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            
            // List of Locations
            List {
                ForEach(mainViewModel.getCurrentLocations()) { location in
                    Button(action: {
                        // Determine which detail view to show based on location type
                        switch location {
                        case .city(let city):
                            selectedCity = city
                        case .companyCity(let companyCity):
                            selectedCompanyCity = companyCity
                        }
                    }) {
                        HStack {
                            // Color-coded icon based on filter type
                            Image(systemName: mainViewModel.currentFilter.icon)
                                .foregroundColor(mainViewModel.colorViewModel.getColor(for: mainViewModel.currentFilter, mapLoc: location))
                            
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .font(.headline)
                                
                                // Show different details based on location type
                                switch location {
                                case .city(let city):
                                    Text("Avg Salary: $\(Int(city.meanSalaryAdjusted).formatted())")
                                        .font(.subheadline)
                                case .companyCity(let companyCity):
                                    Text("Avg Total Comp: $\(Int(companyCity.averageTotalYearlyComp).formatted())")
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(item: $selectedCity) { city in
            CityNavigationView(city: city)
        }
        .sheet(item: $selectedCompanyCity) { companyCity in
            CompanyCityNavigationView(companyCity: companyCity)
        }
    }
}

// Preview
#Preview {
    ListContainer()
        .environmentObject(MainViewModel())
}
