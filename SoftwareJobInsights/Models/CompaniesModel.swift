//
//  CompaniesModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

struct LevelsElement {
    let level: String
    let totalYearlyComp: Int
    let title: String
}

struct CompanyCitySummary {
    let city: String
    var totalTotalYearlyComp: Int
    var numOfJobs: Int
}

struct Company: Identifiable {
    var id: String { company }  // Using company name as the unique identifier
    let company: String
    
    // min and max total yearly comps are useful for normalizing the colors
    var minTotalYearlyComp: Int
    var maxTotalYearlyComp: Int
    
    var avgTotalCompAllLevels: Int?
    var avgTotalCompByLevel: [(String, Int)]?
    
    var cityJobs: [String: [LevelsElement]]
    var citySummaries: [String: CompanyCitySummary]
}

class CompaniesModel {
    var companies: [String: Company] = loadCompaniesFromCSV()
    
    private static func loadCompaniesFromCSV() -> [String: Company] {
        var companies: [String: Company] = [:]
        
        guard let url = Bundle.main.url(forResource: "Levels_Fyi_Salary_Data-Cleaned", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("Failed to load Levels CSV")
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
                                    
            let company = columns[1].capitalized
            let level = columns[2]
            let title = columns[3]
            let totalYearlyComp = Int(columns[4])!
            let city = columns[5]
            
            let job = LevelsElement(
                level: level,
                totalYearlyComp: totalYearlyComp,
                title: title
            )
                        
            if companies[company] == nil {
                companies[company] = Company(company: company, minTotalYearlyComp: totalYearlyComp, maxTotalYearlyComp: totalYearlyComp, cityJobs: [:], citySummaries: [:])
            }
            
            if companies[company]!.cityJobs[city] == nil {
                companies[company]!.cityJobs[city] = []
            }
            if companies[company]!.citySummaries[city] == nil {
                companies[company]!.citySummaries[city] = CompanyCitySummary(city: city, totalTotalYearlyComp: 0, numOfJobs: 0)
            }
                                    
            companies[company]!.cityJobs[city]!.append(job)
            companies[company]!.citySummaries[city]!.totalTotalYearlyComp += totalYearlyComp
            companies[company]!.citySummaries[city]!.numOfJobs += 1
            
            if companies[company]!.minTotalYearlyComp > totalYearlyComp {
                companies[company]!.minTotalYearlyComp = totalYearlyComp
            }
            if companies[company]!.maxTotalYearlyComp < totalYearlyComp {
                companies[company]!.maxTotalYearlyComp = totalYearlyComp
            }
        }
        
        calcAggregateFields(companies: &companies)
        return companies
    }
    
    private static func calcAggregateFields(companies: inout [String: Company]) {
        for company in companies.keys {  // Iterate over keys instead of dictionary
            // the first Int is for the totalTotalComp, the second Int is quantity of jobs
            var totalTotalCompByLevelAndQuantity: [String: (Int, Int)] = [:]
            var totalTotalComp: Int = 0
            var totalTotalQuantity: Int = 0
            
            for city in companies[company]!.cityJobs {
                for lvlsElement in city.value {
                    let lvl = lvlsElement.level
                    let totalYearlyComp = lvlsElement.totalYearlyComp
                    
                    if totalTotalCompByLevelAndQuantity[lvl] == nil {
                        totalTotalCompByLevelAndQuantity[lvl] = (0, 0)
                    }
                    
                    let curVal = totalTotalCompByLevelAndQuantity[lvl]!
                    
                    totalTotalCompByLevelAndQuantity[lvl]! = (curVal.0 + totalYearlyComp, curVal.1 + 1)
                    
                    totalTotalComp += totalYearlyComp  // Fixed: Add the actual comp, not curVal.0
                    totalTotalQuantity += 1
                }
            }
            
            var avgTotalCompByLevel: [(String, Int)] = []
            for (lvl, tots) in totalTotalCompByLevelAndQuantity {
                avgTotalCompByLevel.append((lvl, tots.0 / tots.1))
            }
            
            avgTotalCompByLevel.sort { $0.1 < $1.1 }  // Sort by avg compensation
                                    
            companies[company]!.avgTotalCompByLevel = avgTotalCompByLevel
            companies[company]!.avgTotalCompAllLevels = totalTotalComp / totalTotalQuantity
        }
    }
}
