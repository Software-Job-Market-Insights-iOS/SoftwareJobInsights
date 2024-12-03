//
//  CompaniesModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

struct LevelsElement {
    let level: String
    let city: String
    let totalYearlyComp: Int
    let title: String
}

struct Company {
    var jobs: [LevelsElement]
}

class Companies {
    var companies: [String: Company] = loadCompaniesFromCSV()
    
    private static func loadCompaniesFromCSV() -> [String: Company] {
        var companies: [String: Company] = [:]
        
        guard let url = Bundle.main.url(forResource: "Levels_Fyi_Salary_Data", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("Failed to load CSV")
            return [:]
        }
        
        let rows = content.components(separatedBy: .newlines)
        let headerRow = parseCSVLine(rows[0])
        
        for (index, row) in rows.enumerated() {
            if index == 0 { continue }
            let columns = parseCSVLine(row)
            
            let company = columns[1]
            let level = columns[2]
            let title = columns[3]
            let totalYearlyComp = Int(columns[4])!
            let city = columns[5]
            
            let job = LevelsElement(
                level: level,
                city: city,
                totalYearlyComp: totalYearlyComp,
                title: title
            )
            
            if companies[company] == nil {
                companies[company] = Company(jobs: [])
            }
            
            companies[company]?.jobs.append(job)
        }
        
        return companies
    }
}
