//
//  ColorViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation
import SwiftUI

class ColorViewModel: ObservableObject {
    @Published private var configurations: [FilterType: ColorConfig]
    
    init(cities: [City]) {
        self.configurations = Self.createConfigurations(cities: cities)
    }
    
    private static func createConfigurations(cities: [City]) -> [FilterType: ColorConfig] {
        [
            .adjustedSalary: ColorConfig(
                lowColor: FilterType.adjustedSalary.colorPair.low,
                highColor: FilterType.adjustedSalary.colorPair.high,
                valueRange: calculateRange(values: cities.map { $0.meanSalaryAdjusted })
            ),
            .unadjustedSalary: ColorConfig(
                lowColor: FilterType.unadjustedSalary.colorPair.low,
                highColor: FilterType.unadjustedSalary.colorPair.high,
                valueRange: calculateRange(values: cities.map { $0.meanSalaryUnadjusted })
            ),
            .softwareJobs: ColorConfig(
                lowColor: FilterType.softwareJobs.colorPair.low,
                highColor: FilterType.softwareJobs.colorPair.high,
                valueRange: calculateRange(values: cities.map { Double($0.quantitySoftwareJobs) })
            ),
            .homePrice: ColorConfig(
                lowColor: FilterType.homePrice.colorPair.low,
                highColor: FilterType.homePrice.colorPair.high,
                valueRange: calculateRange(values: cities.map { Double($0.medianHomePrice) })
            )
        ]
    }
    
    private static func calculateRange(values: [Double]) -> ClosedRange<Double> {
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
    
    func getColorConfig(for filterType: FilterType) -> ColorConfig {
        configurations[filterType]!
    }
    
    func getColor(for filterType: FilterType, city: City) -> Color {
        let config = getColorConfig(for: filterType)
        
        let value = switch filterType {
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
}
