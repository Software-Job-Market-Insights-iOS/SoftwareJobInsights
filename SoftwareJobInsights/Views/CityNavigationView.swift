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
                Section("Salary Information") {
                    LabeledContent("Adjusted Salary", value: "$\(Int(city.meanSalaryAdjusted).formatted())")
                    LabeledContent("Unadjusted Salary", value: "$\(Int(city.meanSalaryUnadjusted).formatted())")
                }
                
                Section("Housing") {
                    LabeledContent("Median Home Price", value: "$\(city.medianHomePrice.formatted())")
                    LabeledContent("Average Rent", value: "$\(Int(city.rentAverage).formatted())")
                }
                
                Section("Jobs & Economy") {
                    LabeledContent("Software Jobs", value: city.quantitySoftwareJobs.formatted())
                    LabeledContent("Cost of Living Index", value: String(format: "%.1f", city.costOfLivingAverage))
                }
                
                Section("Demographics") {
                    LabeledContent("Population", value: city.population.formatted())
                    LabeledContent("Density", value: "\(city.density.formatted())/sq mi")
                }
            }
            .navigationTitle(city.name)
        }
        .presentationDetents([.medium])
    }
}
