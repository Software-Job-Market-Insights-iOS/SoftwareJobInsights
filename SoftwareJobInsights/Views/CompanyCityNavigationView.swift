import SwiftUI

struct CompanyCityNavigationView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let companyCity: CompanyCity
    @Environment(\.dismiss) var dismiss
    
    // Computed property to get the city data
    var cityData: City? {
        mainViewModel.getCityByName(name: companyCity.name)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Compensation Header
                Section {
                    VStack(alignment: .center) {
                        Text("$\(Int(companyCity.averageTotalYearlyComp).formatted())")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Average Total Yearly Compensation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if mainViewModel.selectedCompany != companyCity.name {
                            Text("For \(mainViewModel.selectedCompany)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .listRowBackground(Color.clear)
                
                // Compensation Breakdown
                Section("Compensation Details") {
                    LabeledContent("Total Yearly Comp", value: "$\(Int(companyCity.averageTotalYearlyComp).formatted())")
                    LabeledContent("City Mean Salary (Adjusted)",
                                   value: "$\(Int(cityData?.meanSalaryAdjusted ?? 0).formatted())")
                    LabeledContent("City Mean Salary (Unadjusted)",
                                   value: "$\(Int(cityData?.meanSalaryUnadjusted ?? 0).formatted())")
                    LabeledContent("Ratio Company/City", value: "\(String(format: "%.1f", Float(companyCity.averageTotalYearlyComp / (cityData?.meanSalaryUnadjusted ?? 1))))x")
                }
                
                // Job Market Section
                Section("Job Market") {
                    LabeledContent("Number of Datapoints", value: companyCity.numOfJobs.formatted())
                    LabeledContent("Software Jobs in City",
                                   value: cityData?.quantitySoftwareJobs.formatted() ?? "N/A")
                }
                
                // City Economic Indicators
                Section("City Economic Overview") {
                    LabeledContent("Median Home Price",
                                   value: "$\(cityData?.medianHomePrice.formatted() ?? "N/A")")
                    LabeledContent("Cost of Living Index",
                                   value: String(format: "%.1f", cityData?.costOfLivingAverage ?? 0))
                    LabeledContent("Average Rent",
                                   value: "$\(Int(cityData?.rentAverage ?? 0).formatted())")
                }
                
                // Demographic Information
                Section("City Demographics") {
                    LabeledContent("Population",
                                   value: cityData?.population.formatted() ?? "N/A")
                    LabeledContent("Population Density",
                                   value: "\(cityData?.density.formatted() ?? "N/A") per sq mi")
                }
                
                // Additional Context
                Section("Note") {
                    Text("Compensation data is based on aggregated information for \(companyCity.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(companyCity.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
