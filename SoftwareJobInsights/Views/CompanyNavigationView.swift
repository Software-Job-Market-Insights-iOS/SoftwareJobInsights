import SwiftUI

struct CompanyNavigationView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let companyName: String
    let company: Company
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Company-wide Compensation Header
                Section {
                    VStack(alignment: .center) {
                        Text("$\(company.avgTotalCompAllLevels?.formatted() ?? "N/A")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Average Total Yearly Compensation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Across All Levels")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .listRowBackground(Color.clear)
                
                // Compensation Range
                Section("Compensation Range") {
                    LabeledContent("Minimum", value: "$\(company.minTotalYearlyComp.formatted())")
                    LabeledContent("Maximum", value: "$\(company.maxTotalYearlyComp.formatted())")
                    LabeledContent("Spread", value: "$\((company.maxTotalYearlyComp - company.minTotalYearlyComp).formatted())")
                }
                
                // Level Breakdown
                Section("Compensation by Level") {
                    ForEach(mainViewModel.getSortedLevelDataForCompany(companyName: companyName), id: \.0) { level in
                        LabeledContent(level.0,
                                     value: "$\(level.1.formatted())")
                    }
                }
                
//                // Top Cities
//                Section("Top Cities by Average Compensation") {
//                    ForEach(sortedCities.prefix(5), id: \.city) { cityData in
//                        let avgComp = cityData.summary.totalTotalYearlyComp / cityData.summary.numOfJobs
//                        LabeledContent(cityData.city,
//                                     value: "$\(avgComp.formatted())")
//                    }
//                }
                
                // Job Distribution
                Section("Job Distribution") {
                    LabeledContent("Total Locations", value: "\(company.citySummaries.count)")
                    LabeledContent("Total Positions", value: "\(company.cityJobs.values.reduce(0) { $0 + $1.count })")
                    LabeledContent("Unique Levels", value: "\(company.avgTotalCompByLevel?.count ?? 0)")
                }
                
                // Additional Context
                Section("Note") {
                    Text("Data represents aggregated compensation information across all locations for \(company.company)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(company.company)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
