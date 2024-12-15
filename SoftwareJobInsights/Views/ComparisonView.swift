//
//  ComparisonView.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//

import SwiftUI

enum ComparisonMode {
    case city
    case company
}

struct ComparisonView: View {
    @State private var mode: ComparisonMode = .city
    @State private var selectedItems: [Any] = []
    @State private var showingItemPicker = false
    
    // Computed properties for type safety
    var selectedCities: [City] {
        selectedItems.compactMap { $0 as? City }
    }
    
    var selectedCompanies: [CompanyCity] {
        selectedItems.compactMap { $0 as? CompanyCity }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Mode Selector
            Picker("Mode", selection: $mode) {
                Text("Cities").tag(ComparisonMode.city)
                Text("Companies").tag(ComparisonMode.company)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Selected Items Display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        if index < selectedItems.count {
                            ItemCard(item: selectedItems[index], mode: mode)
                        } else if selectedItems.count < 4 {
                            AddItemButton(action: { showingItemPicker = true })
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Comparison Section
            if selectedItems.count >= 2 {
                ScrollView {
                    VStack(spacing: 20) {
                        if mode == .city {
                            CityMetricRows(cities: selectedCities)
                        } else {
                            CompanyMetricRows(companies: selectedCompanies)
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Select at least 2 items",
                    systemImage: "square.stack.3d.up.fill"
                )
            }
        }
        .navigationTitle("Compare \(mode == .city ? "Cities" : "Companies")")
        .sheet(isPresented: $showingItemPicker) {
            ItemPickerView(mode: mode, selectedItems: $selectedItems)
        }
    }
}

struct ItemCard: View {
    let item: Any
    let mode: ComparisonMode
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(getName())
                .font(.headline)
            Text(getSubtitle())
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 150)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func getName() -> String {
        if mode == .city {
            return (item as? City)?.name ?? ""
        } else {
            return (item as? CompanyCity)?.name ?? ""
        }
    }
    
    private func getSubtitle() -> String {
        if mode == .city {
            if let city = item as? City {
                return "\(city.population) people"
            }
        } else {
            if let company = item as? CompanyCity {
                return "\(company.numOfJobs) jobs"
            }
        }
        return ""
    }
}

struct CityMetricRows: View {
    let cities: [City]
    
    var body: some View {
        Group {
            MetricRow(
                title: "Adjusted Mean Salary",
                values: cities.map { "$\(Int($0.meanSalaryAdjusted))" }
            )
            
            MetricRow(
                title: "Unadjusted Mean Salary",
                values: cities.map { "$\(Int($0.meanSalaryUnadjusted))" }
            )
            
            MetricRow(
                title: "Software Jobs",
                values: cities.map { "\($0.quantitySoftwareJobs)" }
            )
            
            MetricRow(
                title: "Median Home Price",
                values: cities.map { "$\($0.medianHomePrice)" }
            )
            
            MetricRow(
                title: "Cost of Living",
                values: cities.map { String(format: "%.1f", $0.costOfLivingAverage) }
            )
            
            MetricRow(
                title: "Average Rent",
                values: cities.map { "$\(Int($0.rentAverage))" }
            )
            
            MetricRow(
                title: "Population",
                values: cities.map { "\($0.population)" }
            )
            
            MetricRow(
                title: "Density",
                values: cities.map { "\($0.density)/km²" }
            )
        }
    }
}

struct CompanyMetricRows: View {
    let companies: [CompanyCity]
    
    var body: some View {
        Group {
            MetricRow(
                title: "Average Total Yearly Comp",
                values: companies.map { "$\(Int($0.averageTotalYearlyComp))" }
            )
            
            MetricRow(
                title: "Number of Jobs",
                values: companies.map { "\($0.numOfJobs)" }
            )
        }
    }
}

struct MetricRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct AddItemButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add Item")
                    .font(.caption)
            }
            .frame(width: 150, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct ItemPickerView: View {
    let mode: ComparisonMode
    @Binding var selectedItems: [Any]
    @Environment(\.dismiss) var dismiss
    
    // Sample data - replace with your actual data source
    let cities = [
        City(id: 1, name: "San Francisco", meanSalaryAdjusted: 120000, meanSalaryUnadjusted: 150000, meanSalaryUnadjustedAllOccupations: 80000, quantitySoftwareJobs: 50000, medianHomePrice: 1200000, costOfLivingAverage: 95.0, rentAverage: 3000, latitude: 37.7749, longitude: -122.4194, population: 874961, density: 18838),
        // Add more cities...
    ]
    
    let companies = [
        CompanyCity(id: 1, name: "Tech Corp", averageTotalYearlyComp: 180000, numOfJobs: 1000, latitude: 37.7749, longitude: -122.4194),
        // Add more companies...
    ]
    
    var body: some View {
        NavigationView {
            List {
                if mode == .city {
                    ForEach(cities) { city in
                        Button(action: {
                            selectedItems.append(city)
                            dismiss()
                        }) {
                            Text(city.name)
                        }
                        .disabled(selectedItems.contains(where: { ($0 as? City)?.id == city.id }))
                    }
                } else {
                    ForEach(companies) { company in
                        Button(action: {
                            selectedItems.append(company)
                            dismiss()
                        }) {
                            Text(company.name)
                        }
                        .disabled(selectedItems.contains(where: { ($0 as? CompanyCity)?.id == company.id }))
                    }
                }
            }
            .navigationTitle("Select \(mode == .city ? "City" : "Company")")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
