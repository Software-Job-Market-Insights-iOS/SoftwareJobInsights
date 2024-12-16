//
//  CoalescedViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//

import Foundation

enum MapLocation: Identifiable, Hashable {
    case city(City)
    case companyCity(CompanyCity)
    
    var id: Int {
        switch self {
        case .city(let city): return city.id
        case .companyCity(let companyCity): return companyCity.id
        }
    }
    
    // Common properties that both types share
    var name: String {
        switch self {
        case .city(let city): return city.name
        case .companyCity(let companyCity): return companyCity.name
        }
    }
    
    var coordinate: (latitude: Float, longitude: Float) {
        switch self {
        case .city(let city):
            return (city.latitude, city.longitude)
        case .companyCity(let companyCity):
            return (companyCity.latitude, companyCity.longitude)
        }
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .city(let city):
            hasher.combine("city")
            hasher.combine(city.id)
        case .companyCity(let companyCity):
            hasher.combine("companyCity")
            hasher.combine(companyCity.id)
        }
    }
    
    // Implement equality for Hashable
    static func == (lhs: MapLocation, rhs: MapLocation) -> Bool {
        switch (lhs, rhs) {
        case (.city(let lhsCity), .city(let rhsCity)):
            return lhsCity.id == rhsCity.id
        case (.companyCity(let lhsCompanyCity), .companyCity(let rhsCompanyCity)):
            return lhsCompanyCity.id == rhsCompanyCity.id
        default:
            return false
        }
    }
}

struct City: Identifiable, Hashable {
    let id: Int
    let name: String
    let meanSalaryAdjusted: Double
    let meanSalaryUnadjusted: Double
    let meanSalaryUnadjustedAllOccupations: Double
    let quantitySoftwareJobs: Int
    let medianHomePrice: Int
    let costOfLivingAverage: Double
    let rentAverage: Double
    
    let latitude: Float
    let longitude: Float
    let population: Int
    let density: Int
}

struct CompanyCity: Identifiable, Hashable {
    let id: Int
    let name: String
    
    let averageTotalYearlyComp: Double
    let numOfJobs: Int
    
    let latitude: Float
    let longitude: Float
}


// MARK: - Coalescing and Connecting the 3 Models
extension MainViewModel {
    // Note:
    // Both CitiesModel and CompaniesModel use String of format: Baltimore, MD for dictionary hashing
        
    static func initAllCities(mainModel: MainModel) -> ([City], [String: Int]) {
        var cities: [City] = []
        var idxOfCities: [String: Int] = [:]
        
        for (idx, (cityName, cityBackend)) in Array(mainModel.cities.cities).enumerated() {
            guard let loc = mainModel.locations.locations[cityName] else {
                print("Warning: No location found for city \(cityName)")
                continue
            }
            
            let city = City(
                id: idx,
                name: cityName,
                
                meanSalaryAdjusted: cityBackend.meanSalaryAdjusted,
                meanSalaryUnadjusted: cityBackend.meanSalaryUnadjusted,
                meanSalaryUnadjustedAllOccupations: cityBackend.meanSalaryUnadjustedAllOccupations,
                quantitySoftwareJobs: cityBackend.quantitySoftwareJobs,
                medianHomePrice: cityBackend.medianHomePrice,
                costOfLivingAverage: cityBackend.costOfLivingAverage,
                rentAverage: cityBackend.rentAverage,
                
                latitude: loc.latitude,
                longitude: loc.longitude,
                population: loc.population,
                density: loc.density
            )
            
            cities.append(city)
            idxOfCities[cityName] = idx
        }
        
        return (cities, idxOfCities)
    }
    
    func getTopCitiesByAdjustedSalary(num: Int) -> [City] {
        let safeNum = min(num, cities.count)
        return cities
            .sorted { $0.meanSalaryAdjusted > $1.meanSalaryAdjusted }
            .prefix(safeNum)
            .map { $0 }
    }
    
    func getTopCitiesByUnadjustedSalary(num: Int) -> [City] {
        let safeNum = min(num, cities.count)
        return cities
            .sorted { $0.meanSalaryUnadjusted > $1.meanSalaryUnadjusted }
            .prefix(safeNum)
            .map { $0 }
    }
    
    func getTopCitiesBySoftwareJobs(num: Int) -> [City] {
        let safeNum = min(num, cities.count)
        return cities
            .sorted { $0.quantitySoftwareJobs > $1.quantitySoftwareJobs }
            .prefix(safeNum)
            .map { $0 }
    }
    
    func getTopCitiesByMedianHomePrice(num: Int) -> [City] {
        let safeNum = min(num, cities.count)
        return cities
            .sorted { $0.medianHomePrice > $1.medianHomePrice }
            .prefix(safeNum)
            .map { $0 }
    }
    
    func getTopCompanyCities(num: Int, sortBy: CompanyCityFilterType) -> [CompanyCity] {
       let company = mainModel.companies.companies[selectedCompany]!
       
       let citySummaries = company.citySummaries
           .values
           .filter { idxOfCities.keys.contains($0.city) }
           .sorted { first, second in
               switch sortBy {
               case .averageTotalComp:
                   return first.totalTotalYearlyComp / first.numOfJobs >
                          second.totalTotalYearlyComp / second.numOfJobs
               case .numJobs:
                   return first.numOfJobs > second.numOfJobs
               }
           }
           .prefix(num)
           .map { $0 }
       
       var companyCities: [CompanyCity] = []
       for (idx, citySummary) in Array(citySummaries).enumerated() {
           guard let loc = mainModel.locations.locations[citySummary.city] else {
               continue
           }
           let companyCity = CompanyCity(
               id: idx,
               name: citySummary.city,
               averageTotalYearlyComp: Double(citySummary.totalTotalYearlyComp / citySummary.numOfJobs),
               numOfJobs: citySummary.numOfJobs,
               latitude: loc.latitude,
               longitude: loc.longitude
           )
           
           companyCities.append(companyCity)
       }
       
       return companyCities
    }
        
    func getCityByName(name: String) -> City {
        return cities[idxOfCities[name]!]
    }
    
    func getNationwideAvgCompForCompany(companyName: String) -> Int {
        return mainModel.companies.companies[companyName]!.avgTotalCompAllLevels!
    }
    
    // String is name of lvl, Int is average total yearly compensation
    func getSortedLevelDataForCompany(companyName: String) -> [(String, Int)] {
        mainModel.companies.companies[companyName]!.avgTotalCompByLevel!
    }
    
    func getCompany(companyName: String) -> Company {
        mainModel.companies.companies[companyName]!
    }
    
    func getNumDatapoints(company: Company) -> Int {
       company.cityJobs.values.reduce(0) { $0 + $1.count }
    }

    func getCompanies(companyFilterType: CompanyCityFilterType) -> [Company] {
       Array(mainModel.companies.companies.values)
           .filter { company in
               getNumDatapoints(company: company) > 20  // using new function
           }
           .sorted { first, second in
               switch companyFilterType {
               case .averageTotalComp:
                   return (first.avgTotalCompAllLevels ?? 0) > (second.avgTotalCompAllLevels ?? 0)
               case .numJobs:
                   return getNumDatapoints(company: first) > getNumDatapoints(company: second)  // using new function
               }
       }
    }
}
