//
//  LocationsModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/5/24.
//
import Foundation

struct LocationCity {
    let city: String
    let stateId: String
    let fips: Int
    let latitude: Float
    let longitude: Float
    let population: Int
    let density: Int
}

class LocationsModel {
    var locations: [LocationCity] = loadLocationsFromCSV()
    
    private static func loadLocationsFromCSV() -> [LocationCity] {
        var locations: [LocationCity] = []
        
        guard let url = Bundle.main.url(forResource: "uscities", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("Failed to load Locations CSV")
            return []
        }
        
        let rows = content.components(separatedBy: .newlines)
        let headerRow = parseCSVLine(rows[0])
        
        for (index, row) in rows.enumerated() {
            if index == 0 { continue }
            let columns = parseCSVLine(row)
                        
            if columns.count != headerRow.count {
                continue
            }
            
            // Convert strings to appropriate types
            let city = columns[0]
            let stateId = columns[2]
            let fips = Int(columns[4])!
            
            let latitude = Float(columns[6])!
            let longitude = Float(columns[7])!
            
            let population = Int(columns[8])!
            let density = Int(columns[9])!
            
            let locationCity = LocationCity(
                city: city,
                stateId: stateId,
                fips: fips,
                latitude: latitude,
                longitude: longitude,
                population: population,
                density: density
            )
                        
            locations.append(locationCity)
        }
        
        return locations
    }
}
