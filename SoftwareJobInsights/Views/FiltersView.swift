import SwiftUI

// Reusable Company Search Component
struct CompanySearchView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !mainViewModel.selectedCompany.isEmpty {
                HStack {
                    Text("Selected Company:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(mainViewModel.selectedCompany)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            
            SearchField(searchText: $mainViewModel.companySearchQuery)
            
            if !mainViewModel.companySearchQuery.isEmpty {
                SearchResults(
                    results: Array(mainViewModel.filteredCompanyNames.prefix(5)),
                    onSelect: { company in
                        mainViewModel.selectedCompany = company
                        mainViewModel.companySearchQuery = ""
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

struct SearchField: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search companies...", text: $searchText)
                .autocorrectionDisabled()
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SearchResults: View {
    let results: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(results, id: \.self) { result in
                SearchResultRow(text: result, onSelect: {
                    onSelect(result)
                })
            }
        }
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct SearchResultRow: View {
    let text: String
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(text)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.05))
        }
    }
}

// Filter Types Component
struct FilterTypesView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(mainViewModel.getFilterTypes(), id: \.self) { filter in
                    Button(action: { mainViewModel.currentFilter = filter }) {
                        Text(filter.title)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(mainViewModel.isCurrentFilter(filter) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(mainViewModel.isCurrentFilter(filter) ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// Main Filters View
struct FiltersView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Mode Switch
            Picker("View Mode", selection: $mainViewModel.isCompanyMode) {
                Text("City").tag(false)
                Text("Company").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Company Search
            if mainViewModel.isCompanyMode {
                CompanySearchView()
            }
            
            // Filter Types
            FilterTypesView()
        }
    }
}

#Preview {
    FiltersView()
        .environmentObject(MainViewModel())
}
