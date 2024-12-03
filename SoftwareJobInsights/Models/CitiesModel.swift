//
//  CitiesModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

struct City {
    let medianCostOfLiving: Int
}

class Cities {
    var cities: [String: City] = loadCitiesFromCSV()
    
    private static func loadCitiesFromCSV() -> [String: City] {
        var cities: [String: City] = [:]
        
        guard let url = Bundle.main.url(forResource: "SoftwareDeveloperIncomeExpensesperUSACity", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("Failed to load Cities CSV")
            return [:]
        }
        
        let rows = content.components(separatedBy: .newlines)
        let headerRow = parseCSVLine(rows[0])
        
        print(headerRow)
        
        for (index, row) in rows.enumerated() {
            if index == 0 { continue }
            let columns = parseCSVLine(row)
            
            if columns.count != headerRow.count {
                continue
            }
            
            let city = columns[7]
        }
        
        return cities
    }
}
