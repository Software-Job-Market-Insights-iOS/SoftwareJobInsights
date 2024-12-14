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
    let idxOfCities: [String: Int]
    
    @Published var selectedLocation: MapLocation?
    
    @Published var isCompanyMode = false
    @Published var selectedCityFilter: CityFilterType = .adjustedSalary
    @Published var numOfCitiesCity: Int = 30
    
    @Published var selectedCompanyFilter: CompanyFilterType = .averageTotalComp
    @Published var companySearchQuery = ""
    @Published var selectedCompany = "Apple"
    @Published var numOfCitiesCompany: Int = 15
    
    init() {
        self.mainModel = MainModel()
        (self.cities, self.idxOfCities) = Self.initAllCities(mainModel: mainModel)
        initializeSortedArrays()
    }
    
    lazy var colorViewModel: ColorViewModel = {
        ColorViewModel(
            cities: self.cities,
            companies: Array(self.mainModel.companies.companies.values)
        )
    }()
    
    private var sortedCitiesByAdjustedSalary: [City] = []
    private var sortedCitiesByUnadjustedSalary: [City] = []
    private var sortedCitiesBySoftwareJobs: [City] = []
    private var sortedCitiesByHomePrice: [City] = []
    private var sortedCompanyCities: [CompanyCity] = []
    
    private func initializeSortedArrays() {
        sortedCitiesByAdjustedSalary = cities.sorted { $0.meanSalaryAdjusted > $1.meanSalaryAdjusted }
        sortedCitiesByUnadjustedSalary = cities.sorted { $0.meanSalaryUnadjusted > $1.meanSalaryUnadjusted }
        sortedCitiesBySoftwareJobs = cities.sorted { $0.quantitySoftwareJobs > $1.quantitySoftwareJobs }
        sortedCitiesByHomePrice = cities.sorted { $0.medianHomePrice > $1.medianHomePrice }
    }
    
    func getCurrentLocations() -> [MapLocation] {
        if isCompanyMode {
            return getTopCompanyCitiesByTotalYearlyComp(num: numOfCitiesCompany)
                .map { MapLocation.companyCity($0) }
        } else {
            let sortedCities: [City]
            switch selectedCityFilter {
            case .adjustedSalary:
                sortedCities = sortedCitiesByAdjustedSalary
            case .unadjustedSalary:
                sortedCities = sortedCitiesByUnadjustedSalary
            case .softwareJobs:
                sortedCities = sortedCitiesBySoftwareJobs
            case .homePrice:
                sortedCities = sortedCitiesByHomePrice
            }
            return sortedCities
                .prefix(numOfCitiesCity)
                .map { MapLocation.city($0) }
        }
    }

    func getFormattedValue(for filterType: FilterType, from mapLocation: MapLocation) -> String {
        switch mapLocation {
        case .city(let city):
            if case let .city(cityFilter) = filterType {
                switch cityFilter {
                case .adjustedSalary:
                    return "$\(Int(city.meanSalaryAdjusted).formatted())"
                case .unadjustedSalary:
                    return "$\(Int(city.meanSalaryUnadjusted).formatted())"
                case .homePrice:
                    return "$\(Int(city.medianHomePrice).formatted())"
                case .softwareJobs:
                    return city.quantitySoftwareJobs.formatted()
                }
            }
            return "0"
            
        case .companyCity(let companyCity):
            if case let .company(companyFilter) = filterType {
                switch companyFilter {
                case .averageTotalComp:
                    return "$\(Int(companyCity.averageTotalYearlyComp).formatted())"
                case .numJobs:
                    return companyCity.numOfJobs.formatted()
                }
            }
            return "0"
        }
    }
    
    func toggleMode() {
        isCompanyMode.toggle()
    }
    
    var filteredCompanyNames: [String] {
        let companyNames = Array(mainModel.companies.companies.keys)
        if companySearchQuery.isEmpty {
            return companyNames
        }
        return companyNames.filter { name in
            name.localizedCaseInsensitiveContains(companySearchQuery)
        }
    }
}
