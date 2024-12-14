//
//  MainView.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    var body: some View {
        NavigationStack {
            TabView {
                MapContainer()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                ListContainer()
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                
                ComparisonView()
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Compare")
                    }
            }
            .navigationDestination(item: $mainViewModel.selectedLocation) { destination in
                switch destination {
                case .city(let city):
                    CityNavigationView(city: city)
                case .companyCity(let companyCity):
                    CompanyCityNavigationView(companyCity: companyCity)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
