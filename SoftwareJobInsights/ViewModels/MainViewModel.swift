//
//  MainViewModel.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import Foundation

class MainViewModel: ObservableObject {
    let mainModel: MainModel
    let cities: [City]
    
    init() {
        self.mainModel = MainModel()
        self.cities = Self.initAllCities(mainModel: mainModel)
    }
}
