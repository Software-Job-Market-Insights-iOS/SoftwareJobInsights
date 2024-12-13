//
//  FilterType.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation

enum FilterType {
    case adjustedSalary
    case unadjustedSalary
    case softwareJobs
    case homePrice
    
    // Only store the static color pairs, the actual range will be initialized by the
    // View Model during runtime based on actual min and max values for attributes
    var colorPair: (low: RGBColor, high: RGBColor) {
        switch self {
        case .adjustedSalary:
            return (RGBColor.lightGreen, RGBColor.darkGreen)
        case .unadjustedSalary:
            return (RGBColor.lightBlue, RGBColor.darkBlue)
        case .softwareJobs:
            return (RGBColor.lightPurple, RGBColor.darkPurple)
        case .homePrice:
            return (RGBColor.lightOrange, RGBColor.darkOrange)
        }
    }
}
