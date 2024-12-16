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
        if mainViewModel.isLocationMode {
            mainViewModel.isCompanyCityMode ? mainViewModel.companyCitiesQueue.count : mainViewModel.citiesQueue.count
        } else {
            mainViewModel.companiesQueue.count
        }
    }
        
    var body: some View {
        VStack(spacing: 16) {
            
            FiltersView(showAttributes: false)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Group {
                        if mainViewModel.isLocationMode {
                            if mainViewModel.isCompanyCityMode {
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
                        } else {
                            ForEach(mainViewModel.companiesQueue) { company in
                                ItemCard(company: company)
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
                .animation(.spring, value: mainViewModel.companiesQueue)
            }
            
            // Comparison Section
            if getCurNumQueueItems() >= 2 {
                ScrollView {
                    VStack(spacing: 20) {
                        if mainViewModel.isLocationMode {
                            if mainViewModel.isCompanyCityMode {
                                CompanyCityMetricRows(companies: mainViewModel.companyCitiesQueue)
                            } else {
                                CityMetricRows(cities: mainViewModel.citiesQueue)
                            }
                        } else {
                            CompanyDetailMetricRows(companies: mainViewModel.companiesQueue)
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
        .navigationTitle("Compare \(mainViewModel.isCompanyCityMode ? "Companies" : "Cities")")
        .sheet(isPresented: $showingItemPicker) {
            ItemPickerView()
        }
    }
}

struct ItemCard: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    var city: City? = nil
    var companyCity: CompanyCity? = nil
    var company: Company? = nil
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            VStack(alignment: .leading) {
                if let city = city {
                    Text(city.name)
                        .font(.headline)
                        .padding(.trailing, 24)
                    Text("$\(city.meanSalaryAdjusted.formatted())")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if let companyCity = companyCity {
                    Text(companyCity.name)
                        .font(.headline)
                        .padding(.trailing, 24)
                    Text("\(companyCity.numOfJobs) datapoints")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if let company = company {
                    Text(company.company)
                        .font(.headline)
                        .padding(.trailing, 24)
                    Text("$\(company.avgTotalCompAllLevels!)")
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
                } else if let companyCity = companyCity {
                    mainViewModel.companyCitiesQueue.removeAll(where: { $0.id == companyCity.id })
                } else if let company = company {
                    mainViewModel.companiesQueue.removeAll(where: { $0.id == company.id })
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
                values: cities.map { ("$\(Int($0.meanSalaryAdjusted))", false) }  // Higher is better
            )
            
            MetricRow(
                title: "Unadjusted Mean Salary",
                values: cities.map { ("$\(Int($0.meanSalaryUnadjusted))", false) }  // Higher is better
            )
            
            MetricRow(
                title: "Software Jobs",
                values: cities.map { ("\($0.quantitySoftwareJobs)", false) }  // Higher is better
            )
            
            MetricRow(
                title: "Median Home Price",
                values: cities.map { ("$\($0.medianHomePrice)", true) }  // Lower is better
            )
            
            MetricRow(
                title: "Cost of Living",
                values: cities.map { (String(format: "%.1f", $0.costOfLivingAverage), true) }  // Lower is better
            )
            
            MetricRow(
                title: "Average Rent",
                values: cities.map { ("$\(Int($0.rentAverage))", true) }  // Lower is better
            )
            
            MetricRow(
                title: "Population",
                values: cities.map { ("\($0.population)", false) }  // Neutral, but using higher=better
            )
            
            MetricRow(
                title: "Density",
                values: cities.map { ("\($0.density)/km²", false) }  // Neutral, but using higher=better
            )
        }
    }
}

struct CompanyCityMetricRows: View {
    let companies: [CompanyCity]
    
    var body: some View {
        Group {
            MetricRow(
                title: "Average Total Yearly Comp",
                values: companies.map { ("$\(Int($0.averageTotalYearlyComp))", false) }  // Higher is better
            )
            
            MetricRow(
                title: "Number of Jobs",
                values: companies.map { ("\($0.numOfJobs)", false) }  // Higher is better
            )
        }
    }
}

struct CompanyDetailMetricRows: View {
    let companies: [Company]
    @EnvironmentObject var mainViewModel: MainViewModel
    
    var body: some View {
        Group {
            MetricRow(
                title: "Average Total Compensation",
                values: companies.map { ("\(($0.avgTotalCompAllLevels ?? 0).formatted())", false) }
            )
            
            MetricRow(
                title: "Total Datapoints",
                values: companies.map { ("\(mainViewModel.getNumDatapoints(company: $0))", false) }
            )
        }
    }
}

struct MetricRow: View {
   let title: String
   let values: [(String, Bool)]  // (value, isReversed)
   
   private func numericValue(_ str: String) -> Double {
       let numStr = str.replacingOccurrences(of: "[$,/km²]", with: "", options: .regularExpression)
       return Double(numStr) ?? 0
   }
   
   private func formattedValue(_ str: String) -> String {
       if str.hasPrefix("$") {
           let num = numericValue(str)
           return "$" + NumberFormatter.localizedString(from: NSNumber(value: num), number: .decimal)
       } else if str.hasSuffix("/km²") {
           let num = numericValue(str)
           return NumberFormatter.localizedString(from: NSNumber(value: num), number: .decimal) + "/km²"
       } else {
           let num = numericValue(str)
           return NumberFormatter.localizedString(from: NSNumber(value: num), number: .decimal)
       }
   }
   
   var body: some View {
       VStack(alignment: .leading, spacing: 8) {
           Text(title)
               .font(.headline)
           
           HStack {
               ForEach(Array(values.enumerated()), id: \.offset) { index, valueAndReverse in
                   let (value, isReversed) = valueAndReverse
                   let currentValue = numericValue(value)
                   let maxValue = values.map { numericValue($0.0) }.max() ?? 0
                   let minValue = values.map { numericValue($0.0) }.min() ?? 0
                   
                   let isHighest = currentValue == maxValue
                   let isLowest = currentValue == minValue
                   
                   Text(formattedValue(value))
                       .frame(maxWidth: .infinity)
                       .padding(8)
                       .background(
                           isHighest ? Color(isReversed ? .red : .green).opacity(0.1) :
                               isLowest ? Color(isReversed ? .green : .red).opacity(0.1) :
                               Color.blue.opacity(0.1)
                       )
                       .foregroundColor(
                           isHighest ? Color(isReversed ? .red : .green) :
                               isLowest ? Color(isReversed ? .green : .red) :
                               .blue
                       )
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
            Group {
                if !mainViewModel.isLocationMode {
                    CompanyPickerList(dismiss: dismiss)
                } else {
                    LocationPickerList(dismiss: dismiss)
                }
            }
            .navigationTitle(!mainViewModel.isLocationMode ? "Select Company" : "Select City")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct CompanyPickerList: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let dismiss: DismissAction
    
    var body: some View {
        List {
            ForEach(mainViewModel.getCompanies(companyFilterType: mainViewModel.selectedCompanyFilter)) { company in
                CompanyPickerRow(company: company, dismiss: dismiss)
            }
        }
    }
}

struct CompanyPickerRow: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let company: Company
    let dismiss: DismissAction
    
    var body: some View {
        Button(action: {
            mainViewModel.companiesQueue.append(company)
            dismiss()
        }) {
            Text(company.company)
        }
        .disabled(mainViewModel.companiesQueue.contains { $0.company == company.company })    }
}

struct LocationPickerList: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let dismiss: DismissAction
    
    var body: some View {
        List {
            ForEach(mainViewModel.getCurrentLocations()) { mapLoc in
                LocationPickerRow(mapLoc: mapLoc, dismiss: dismiss)
            }
        }
    }
    
    func isAlreadySelected(_ mapLoc: MapLocation) -> Bool {
        switch mapLoc {
        case .city(let city):
            return mainViewModel.citiesQueue.contains(city)
        case .companyCity(let companyCity):
            return mainViewModel.companyCitiesQueue.contains(companyCity)
        }
    }
}

struct LocationPickerRow: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let mapLoc: MapLocation
    let dismiss: DismissAction
    
    var body: some View {
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
        .disabled(isAlreadySelected(mapLoc))
    }
    
    private func isAlreadySelected(_ mapLoc: MapLocation) -> Bool {
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
