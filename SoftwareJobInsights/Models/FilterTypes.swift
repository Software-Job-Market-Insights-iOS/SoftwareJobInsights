//
//  FilterType.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/13/24.
//

import Foundation

enum FilterType: Identifiable, Equatable, Hashable {
    case city(CityFilterType)
    case companyCity(CompanyFilterType)
    
    var id: String {
        switch self {
        case .city(let cityFilter):
            return "city_\(cityFilter.id)"
        case .companyCity(let companyFilter):
            return "company_\(companyFilter.id)"
        }
    }
    
    static func == (lhs: FilterType, rhs: FilterType) -> Bool {
        switch (lhs, rhs) {
        case (.city(let a), .city(let b)): return a == b
        case (.companyCity(let a), .companyCity(let b)): return a == b
        default: return false
        }
    }
    
    static func getAllCases(isCompanyMode: Bool) -> [FilterType] {
        if isCompanyMode {
            return CompanyFilterType.allCases.map { .companyCity($0) }
        } else {
            return CityFilterType.allCases.map { .city($0) }
        }
    }
    
    var title: String {
        switch self {
        case .city(let cityFilter):
            return cityFilter.title
        case .companyCity(let companyFilter):
            return companyFilter.title
        }
    }
    
    var icon: String {
        switch self {
        case .city(let cityFilter):
            return cityFilter.icon
        case .companyCity(let companyFilter):
            return companyFilter.icon
        }
    }
}

enum CompanyFilterType: Identifiable, CaseIterable {
    case averageTotalComp
    case numJobs
    
    var id: Self { self }
    
    var colorPair: (low: RGBColor, high: RGBColor) {
        switch self {
        case .averageTotalComp:
            return (RGBColor.lightGreen, RGBColor.darkGreen)
        case .numJobs:
            return (RGBColor.lightBlue, RGBColor.darkBlue)
        }
    }
    
    var title: String {
        switch self {
        case .averageTotalComp: return "Average Total Compensation"
        case .numJobs: return "Number of Jobs"
        }
    }
    
    var icon: String {
        switch self {
        case .averageTotalComp: return "dollarsign.circle.fill"
        case .numJobs: return "briefcase.fill"
        }
    }
}

enum CityFilterType: Identifiable, CaseIterable {
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


