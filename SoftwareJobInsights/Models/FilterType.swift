//
//  FilterType.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation

enum FilterType: Identifiable {
    case adjustedSalary
    case unadjustedSalary
    case softwareJobs
    case homePrice
    
    var id: Self { self }
    
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
    
    var title: String {
        switch self {
        case .adjustedSalary: return "Adjusted Salary"
        case .unadjustedSalary: return "Unadjusted Salary"
        case .softwareJobs: return "Software Jobs"
        case .homePrice: return "Home Price"
        }
    }
    
    var icon: String {
        switch self {
        case .adjustedSalary: return "dollarsign.circle.fill"
        case .unadjustedSalary: return "banknote.fill"
        case .softwareJobs: return "laptopcomputer"
        case .homePrice: return "house.fill"
        }
    }
}
