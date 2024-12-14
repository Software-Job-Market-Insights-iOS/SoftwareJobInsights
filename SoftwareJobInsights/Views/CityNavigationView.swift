//
//  CityDetailView.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/14/24.
//

import SwiftUI

struct CityNavigationView: View {
    let city: City
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Salary Header
                Section {
                    VStack(alignment: .center) {
                        Text("$\(Int(city.meanSalaryAdjusted).formatted())")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Average Adjusted Salary")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .listRowBackground(Color.clear)
                
                Section("Salary Insights") {
                    LabeledContent("Adjusted Salary", value: "$\(Int(city.meanSalaryAdjusted).formatted())")
                    LabeledContent("Unadjusted Salary", value: "$\(Int(city.meanSalaryUnadjusted).formatted())")
                    LabeledContent("Unadjusted Salary (All Occupations)",
                                   value: "$\(Int(city.meanSalaryUnadjustedAllOccupations).formatted())")
                }
                
                Section("Housing Market") {
                    LabeledContent("Median Home Price", value: "$\(city.medianHomePrice.formatted())")
                    LabeledContent("Average Rent", value: "$\(Int(city.rentAverage).formatted())")
                    
                    // Housing Affordability Calculation
                    if city.meanSalaryAdjusted > 0 {
                        let homeToSalaryRatio = Double(city.medianHomePrice) / city.meanSalaryAdjusted
                        LabeledContent("Home Price to Salary Ratio",
                                       value: String(format: "%.1f", homeToSalaryRatio))
                    }
                }
                
                Section("Jobs & Economy") {
                    LabeledContent("Software Jobs", value: city.quantitySoftwareJobs.formatted())
                    LabeledContent("Cost of Living Index", value: String(format: "%.1f", city.costOfLivingAverage))
                    
                    // Job Market Density
                    if city.population > 0 {
                        let softwareJobDensity = Double(city.quantitySoftwareJobs) / Double(city.population) * 1000
                        LabeledContent("Software Jobs per 1,000 People",
                                       value: String(format: "%.2f", softwareJobDensity))
                    }
                }
                
                Section("Demographics") {
                    LabeledContent("Population", value: city.population.formatted())
                    LabeledContent("Population Density", value: "\(city.density.formatted())/sq mi")
                    
                    // Additional Demographic Insights
                    if city.population > 0 && city.density > 0 {
                        let urbanizationScore = log(Double(city.population)) / log(Double(city.density))
                        LabeledContent("Urbanization Score",
                                       value: String(format: "%.2f", urbanizationScore))
                    }
                }
                
                Section("Note") {
                    Text("This data provides a comprehensive overview of the economic and demographic landscape in \(city.name).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
