//
//  CoalescedViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//

import Foundation

enum MapLocation: Identifiable {
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
}

struct City: Identifiable {
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

struct CompanyCity: Identifiable {
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
        
    static func initAllCities(mainModel: MainModel) -> [City] {
        var cities: [City] = []
        
        for (cityName, cityBackend) in Array(mainModel.cities.cities) {
            let loc = mainModel.locations.locations[cityName]!
            
            let city = City(
                id: loc.fips,
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
        }
        
        return cities
    }
    
    func getTopCitiesByAdjustedSalary(num: Int) -> [City] {
        return cities
            .sorted { $0.meanSalaryAdjusted > $1.meanSalaryAdjusted }
            .prefix(num)
            .map { $0 }
    }
    
    func getTopCitiesByUnadjustedSalary(num: Int) -> [City] {
        return cities
            .sorted { $0.meanSalaryUnadjusted > $1.meanSalaryUnadjusted }
            .prefix(num)
            .map { $0 }
    }
    
    func getTopCitiesBySoftwareJobs(num: Int) -> [City] {
        return cities
            .sorted { $0.quantitySoftwareJobs > $1.quantitySoftwareJobs }
            .prefix(num)
            .map { $0 }
    }
    
    func getTopCitiesByMedianHomePrice(num: Int) -> [City] {
        return cities
            .sorted { $0.medianHomePrice > $1.medianHomePrice }
            .prefix(num)
            .map { $0 }
    }
    
    func getTopCompanyCitiesByTotalYearlyComp(num: Int) -> [CompanyCity] {
        let company = mainModel.companies.companies[selectedCompany]!
        
        let citySummaries = company.citySummaries
            .values
            .sorted { $0.totalTotalYearlyComp / $0.numOfJobs > $1.totalTotalYearlyComp / $1.numOfJobs }
            .prefix(num)
            .map { $0 }
        
        var companyCities: [CompanyCity] = []
        for citySummary in citySummaries {
            let loc = mainModel.locations.locations[citySummary.city]!
            
            let companyCity = CompanyCity(id: loc.fips, name: citySummary.city,averageTotalYearlyComp: Double(citySummary.totalTotalYearlyComp / citySummary.numOfJobs), numOfJobs: citySummary.numOfJobs, latitude: loc.latitude, longitude: loc.longitude)
            
            companyCities.append(companyCity)
        }
        
        return companyCities
    }
}
