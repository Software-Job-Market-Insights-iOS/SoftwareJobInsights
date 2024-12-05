//
//  MainViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

class MainViewModel: ObservableObject {
    let mainModel: MainModel = MainModel()
    
    // Cities Specific Getters
    func getAllCityNames() -> [String] {
        Array(mainModel.cities.cities.keys)
    }
    
    
    
    
    
}
