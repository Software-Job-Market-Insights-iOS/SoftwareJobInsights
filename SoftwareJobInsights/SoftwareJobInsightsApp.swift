//
//  SoftwareJobInsightsApp.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import SwiftUI

@main
struct SoftwareJobInsightsApp: App {
    var mainViewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(mainViewModel)
        }
    }
}
