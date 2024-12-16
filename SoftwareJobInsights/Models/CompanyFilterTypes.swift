//
//  CompanyFilterTypes.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/15/24.
//

import Foundation

enum CompanyFilterType: Identifiable, CaseIterable {
    case averageTotalComp
    case numDatapoints

    var id: Self { self }
    
    var colorPair: (low: RGBColor, high: RGBColor) {
        switch self {
        case .averageTotalComp:
            return (RGBColor.lightGreen, RGBColor.darkGreen)
        case .numDatapoints:
            return (RGBColor.lightBlue, RGBColor.darkBlue)
        }
    }
    
    var title: String {
        switch self {
        case .averageTotalComp: return "Average Total Compensation"
        case .numDatapoints: return "Number of Datapoints"
        }
    }
    
    var icon: String {
        switch self {
        case .averageTotalComp: return "dollarsign.circle.fill"
        case .numDatapoints: return "person.3.fill"
        }
    }
}
