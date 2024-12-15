//
//  FilterTypesViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/14/24.
//

import Foundation

extension MainViewModel {
    
    var currentFilter: FilterType {
        get {
            isCompanyMode ? .company(selectedCompanyFilter) : .city(selectedCityFilter)
        }
        set {
            switch newValue {
            case .city(let cityFilter):
                selectedCityFilter = cityFilter
            case .company(let companyFilter):
                selectedCompanyFilter = companyFilter
            }
        }
    }
    
    func getFilterTypes() -> [FilterType] {
        FilterType.getAllCases(isCompanyMode: isCompanyMode)
    }
    
    func isCurrentFilter(_ filter: FilterType) -> Bool {
        switch (currentFilter, filter) {
        case (.city(let currentCity), .city(let otherCity)):
            return currentCity == otherCity
        case (.company(let currentCompany), .company(let otherCompany)):
            return currentCompany == otherCompany
        default:
            return false
        }
    }
}
