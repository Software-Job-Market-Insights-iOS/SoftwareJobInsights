//
//  MainModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

func parseCSVLine(_ line: String) -> [String] {
    var result: [String] = []
    var currentField = ""
    var insideQuotes = false
    
    for char in line {
        switch char {
        case "\"":
            insideQuotes.toggle()
        case ",":
            if !insideQuotes {
                result.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        default:
            currentField.append(char)
        }
    }
    
    result.append(currentField.trimmingCharacters(in: .whitespaces))
    return result
}


class MainModel {
    let companies: CompaniesModel = CompaniesModel()
    let cities: CitiesModel = CitiesModel()
    let locations: LocationsModel = LocationsModel()
}
