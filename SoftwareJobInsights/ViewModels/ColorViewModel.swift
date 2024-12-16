//
//  ColorViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation
import SwiftUI

class ColorViewModel: ObservableObject {
    @Published private var cityConfigurations: [CityFilterType: ColorConfig]
    @Published private var companyConfigurations: [CompanyCityFilterType: ColorConfig]
    
    init(cities: [City], companies: [Company]) {
        self.cityConfigurations = Self.createConfigurations(cities: cities)
        self.companyConfigurations = Self.createCompanyConfigurations(companies: companies)
    }
    
    private static func createConfigurations(cities: [City]) -> [CityFilterType: ColorConfig] {
        [
            .adjustedSalary: ColorConfig(
                lowColor: CityFilterType.adjustedSalary.colorPair.low,
                highColor: CityFilterType.adjustedSalary.colorPair.high,
                valueRange: calculateRange(values: cities.map { $0.meanSalaryAdjusted })
            ),
            .unadjustedSalary: ColorConfig(
                lowColor: CityFilterType.unadjustedSalary.colorPair.low,
                highColor: CityFilterType.unadjustedSalary.colorPair.high,
                valueRange: calculateRange(values: cities.map { $0.meanSalaryUnadjusted })
            ),
            .softwareJobs: ColorConfig(
                lowColor: CityFilterType.softwareJobs.colorPair.low,
                highColor: CityFilterType.softwareJobs.colorPair.high,
                valueRange: calculateRange(values: cities.map { Double($0.quantitySoftwareJobs) })
            ),
            .homePrice: ColorConfig(
                lowColor: CityFilterType.homePrice.colorPair.low,
                highColor: CityFilterType.homePrice.colorPair.high,
                valueRange: calculateRange(values: cities.map { Double($0.medianHomePrice) })
            )
        ]
    }
    
    private static func createCompanyConfigurations(companies: [Company]) -> [CompanyCityFilterType: ColorConfig] {
        [
            .averageTotalComp: ColorConfig(
                lowColor: CompanyCityFilterType.averageTotalComp.colorPair.low,
                highColor: CompanyCityFilterType.averageTotalComp.colorPair.high,
                valueRange: calculateRange(values: companies.flatMap { company in
                    company.citySummaries.values.map { Double($0.totalTotalYearlyComp) / Double($0.numOfJobs) }
                })
            ),
            .numJobs: ColorConfig(
                lowColor: CompanyCityFilterType.numJobs.colorPair.low,
                highColor: CompanyCityFilterType.numJobs.colorPair.high,
                valueRange: calculateRange(values: companies.flatMap { company in
                    company.citySummaries.values.map { Double($0.numOfJobs) }
                })
            )
        ]
    }
    
    private static func calculateRange(values: [Double]) -> ClosedRange<Double> {
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
    
    private func getColorCityMode(city: City, filter: CityFilterType) -> Color {
        let config = cityConfigurations[filter]!
        
        let value = switch filter {
        case .adjustedSalary:
            city.meanSalaryAdjusted
        case .unadjustedSalary:
            city.meanSalaryUnadjusted
        case .homePrice:
            Double(city.medianHomePrice)
        case .softwareJobs:
            Double(city.quantitySoftwareJobs)
        }
                
        // Normalize the value
        let normalized = (value - config.valueRange.lowerBound) /
            (config.valueRange.upperBound - config.valueRange.lowerBound)
        let clamped = max(0, min(1, normalized))
        
        // Interpolate between colors
        let r = config.lowColor.red + (config.highColor.red - config.lowColor.red) * clamped
        let g = config.lowColor.green + (config.highColor.green - config.lowColor.green) * clamped
        let b = config.lowColor.blue + (config.highColor.blue - config.lowColor.blue) * clamped
        
        return Color(red: r, green: g, blue: b)
    }
    
    private func getColorCompanyMode(companyCity: CompanyCity, filter: CompanyCityFilterType) -> Color {
        let config = companyConfigurations[filter]!
        
        let value = switch filter {
        case .averageTotalComp:
            companyCity.averageTotalYearlyComp
        case .numJobs:
            Double(companyCity.numOfJobs)
        }
            
        let normalized = (value - config.valueRange.lowerBound) /
            (config.valueRange.upperBound - config.valueRange.lowerBound)
        let clamped = max(0, min(1, normalized))
        
        let r = config.lowColor.red + (config.highColor.red - config.lowColor.red) * clamped
        let g = config.lowColor.green + (config.highColor.green - config.lowColor.green) * clamped
        let b = config.lowColor.blue + (config.highColor.blue - config.lowColor.blue) * clamped
        
        return Color(red: r, green: g, blue: b)
    }
    
    func getColor(for filterType: MapLocFilterType, mapLoc: MapLocation) -> Color {
        switch mapLoc {
        case .city(let city):
            if case .city(let cityFilter) = filterType {
                return getColorCityMode(city: city, filter: cityFilter)
            }
            return .gray
        case .companyCity(let companyCity):
            if case .companyCity(let companyFilter) = filterType {
                return getColorCompanyMode(companyCity: companyCity, filter: companyFilter)
            }
            return .gray
        }
    }
}
