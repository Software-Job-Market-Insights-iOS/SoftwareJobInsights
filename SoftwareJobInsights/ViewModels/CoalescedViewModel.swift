//
//  CoalescedViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//

import Foundation

struct CityNameLocId: Identifiable {
    let cityName: String
    let lat: Float
    let long: Float
    let id: Int
}

// MARK: - Coalescing and Connecting the 3 Models
extension MainViewModel {
    // Note:
    // Both CitiesModel and CompaniesModel use String of format: Baltimore, MD for dictionary hashing
    
    func getAllCityNamesLocId() -> [CityNameLocId] {
        var cityNameLocIds: [CityNameLocId] = []
        
        for cityName in Array(mainModel.cities.cities.keys) {
            let loc = mainModel.locations.locations[cityName]!
            
            let lat = loc.latitude
            let long = loc.longitude
            
            let id = loc.fips
            
            let newElement = CityNameLocId(cityName: cityName, lat: lat, long: long, id: id)
            cityNameLocIds.append(newElement)
        }
        
        return cityNameLocIds
    }
}
