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
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State private var showingItemPicker: Bool = false

    func getCurNumQueueItems() -> Int {
        mainViewModel.isCompanyMode ? mainViewModel.companyCitiesQueue.count : mainViewModel.citiesQueue.count
    }
        
    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $mainViewModel.isCompanyMode) {
                Text("Cities").tag(false)
                Text("Companies").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if mainViewModel.isCompanyMode {
                CompanySearchView()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Group {
                        if mainViewModel.isCompanyMode {
                            ForEach(mainViewModel.companyCitiesQueue) { company in
                                ItemCard(companyCity: company)
                                    .transition(.scale)
                            }
                        } else {
                            ForEach(mainViewModel.citiesQueue) { city in
                                ItemCard(city: city)
                                    .transition(.scale)
                            }
                        }
                    }
                    
                    if getCurNumQueueItems() < 4 {
                        ForEach(0..<(4 - getCurNumQueueItems()), id: \.self) { _ in
                            AddItemButton(action: { showingItemPicker = true })
                                .transition(.scale)
                        }
                    }
                }
                .padding(.horizontal)
                .animation(.spring, value: mainViewModel.companyCitiesQueue)
                .animation(.spring, value: mainViewModel.citiesQueue)
            }
            
            // Comparison Section
            if getCurNumQueueItems() >= 2 {
                ScrollView {
                    VStack(spacing: 20) {
                        if mainViewModel.isCompanyMode {
                            CompanyMetricRows(companies: mainViewModel.companyCitiesQueue)
                        } else {
                            CityMetricRows(cities: mainViewModel.citiesQueue)
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
        .navigationTitle("Compare \(mainViewModel.isCompanyMode ? "Companies" : "Cities")")
        .sheet(isPresented: $showingItemPicker) {
            ItemPickerView()
        }
    }
}

struct ItemCard: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    var city: City? = nil
    var companyCity: CompanyCity? = nil
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            VStack(alignment: .leading) {
                if let city = city {
                    Text(city.name)
                        .font(.headline)
                        .padding(.trailing, 24)
                    Text("\(city.population) people")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if let company = companyCity {
                    Text(company.name)
                        .font(.headline)
                        .padding(.trailing, 24)
                    Text("\(company.numOfJobs) jobs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(width: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: {
                if let city = city {
                    mainViewModel.citiesQueue.removeAll(where: { $0.id == city.id })
                } else if let company = companyCity {
                    mainViewModel.companyCitiesQueue.removeAll(where: { $0.id == company.id })
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            .padding(8)
        }
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
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(mainViewModel.getCurrentLocations()) { mapLoc in
                    Button(action: {
                        switch mapLoc {
                        case .city(let city):
                            mainViewModel.citiesQueue.append(city)
                        case .companyCity(let companyCity):
                            mainViewModel.companyCitiesQueue.append(companyCity)
                        }
                        dismiss()
                    }) {
                        Text(mapLoc.name)
                    }
                    .disabled(isAlreadySelected(mapLoc, mainViewModel: mainViewModel))
                }
            }
            .navigationTitle("Select City")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func isAlreadySelected(_ mapLoc: MapLocation, mainViewModel: MainViewModel) -> Bool {
        switch mapLoc {
        case .city(let city):
            return mainViewModel.citiesQueue.contains(city)
        case .companyCity(let companyCity):
            return mainViewModel.companyCitiesQueue.contains(companyCity)
        }
    }
}

#Preview {
    ComparisonView()
        .environmentObject(MainViewModel())
}
