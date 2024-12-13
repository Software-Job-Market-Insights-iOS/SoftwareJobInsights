//
//  MainViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

class MainViewModel: ObservableObject {
    let mainModel: MainModel
    let cities: [City]
    let colorViewModel: ColorViewModel
    
    @Published var selectedFilter: FilterType = .unadjustedSalary
    @Published var numberOfCities: Int = 30
    
    @Published var isCompanyMode = false
    @Published var selectedCompany = "Apple"
    
    init() {
        self.mainModel = MainModel()
        self.cities = Self.initAllCities(mainModel: mainModel)
        self.colorViewModel = ColorViewModel(cities: self.cities)
    }
    
    func getCurrentLocations(num: Int) -> [MapLocation] {
        if isCompanyMode {
            return getTopCompanyCitiesByTotalYearlyComp(num: num)
                .map { MapLocation.companyCity($0) }
        } else {
            switch selectedFilter {
            case .adjustedSalary:
                return getTopCitiesByAdjustedSalary(num: num)
                    .map { MapLocation.city($0) }
            case .unadjustedSalary:
                return getTopCitiesByUnadjustedSalary(num: num)
                    .map { MapLocation.city($0) }
            case .softwareJobs:
                return getTopCitiesBySoftwareJobs(num: num)
                    .map { MapLocation.city($0) }
            case .homePrice:
                return getTopCitiesByMedianHomePrice(num: num)
                    .map { MapLocation.city($0) }
            }
        }
    }
    
    func getFilterTypes() -> [FilterType] {
        [
            .adjustedSalary,
            .unadjustedSalary,
            .softwareJobs,
            .homePrice
        ]
    }
    
    func getFormattedValue(for filterType: FilterType, from city: City) -> String {
       switch filterType {
       case .adjustedSalary, .unadjustedSalary, .homePrice:
           let value = switch filterType {
           case .adjustedSalary: city.meanSalaryAdjusted
           case .unadjustedSalary: city.meanSalaryUnadjusted
           case .homePrice: Double(city.medianHomePrice)
           default: 0.0 // This won't be reached but is needed for exhaustiveness
           }
           return "$\(Int(value).formatted())"
           
       case .softwareJobs:
           return city.quantitySoftwareJobs.formatted()
       }
    }
    
    func toggleMode() {
        isCompanyMode.toggle()
    }
}
