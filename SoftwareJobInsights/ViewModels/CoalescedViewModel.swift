//
//  CoalescedViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//

import Foundation


struct City: Identifiable {
    let id: Int  // Add this line
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
}
