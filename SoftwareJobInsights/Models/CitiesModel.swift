//
//  CitiesModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

struct CityBackend {
    let id: Int
    let name: String
    let meanSalaryAdjusted: Double
    let meanSalaryUnadjusted: Double
    let meanSalaryUnadjustedAllOccupations: Double
    let quantitySoftwareJobs: Int
    let medianHomePrice: Int
    let costOfLivingAverage: Double
    let rentAverage: Double
}

class CitiesModel {
    var cities: [String: CityBackend] = loadCitiesFromCSV()
    
    private static func loadCitiesFromCSV() -> [String: CityBackend] {
        var cities: [String: CityBackend] = [:]
        
        guard let url = Bundle.main.url(forResource: "SoftwareDeveloperIncomeExpensesperUSACity", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("Failed to load Cities CSV")
            return [:]
        }
        
        let rows = content.components(separatedBy: .newlines)
        let headerRow = parseCSVLine(rows[0])
                        
        for (index, row) in rows.enumerated() {
            if index == 0 { continue }
            let columns = parseCSVLine(row)
            
            if columns.count != headerRow.count {
                continue
            }
                        
            // Convert string values to appropriate types with 1 decimal point precision
            let meanSalaryAdjusted = Double(columns[2])!.rounded(to: 1)
            let meanSalaryUnadjusted = Double(columns[3])!.rounded(to: 1)
            let meanSalaryUnadjustedAllOccups = Double(columns[4])!.rounded(to: 1)
            
            let quantitySoftwareJobs = Int(Double(columns[5])!)
            let medianHomePrice = Int(Double(columns[6])!)
            
            let city = columns[7]
            
            let costOfLivingAvg = Double(columns[8])!.rounded(to: 1)
            let rentAvg = Double(columns[9])!.rounded(to: 1)
            
            let cityObject = CityBackend(
                id: index,
                name: city,
                meanSalaryAdjusted: meanSalaryAdjusted,
                meanSalaryUnadjusted: meanSalaryUnadjusted,
                meanSalaryUnadjustedAllOccupations: meanSalaryUnadjustedAllOccups,
                quantitySoftwareJobs: quantitySoftwareJobs,
                medianHomePrice: medianHomePrice,
                costOfLivingAverage: costOfLivingAvg,
                rentAverage: rentAvg
            )
                        
            cities[city] = cityObject
        }
        
        return cities
    }
}

// Extension to round Double to specified decimal places
extension Double {
    func rounded(to places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
