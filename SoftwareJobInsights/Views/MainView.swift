//
//  MainView.swift
//  SoftwareJobInsights
//
//  Created by Caverly, Quinn on 12/3/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
//            MapView()
//                .tabItem {
//                    Image(systemName: "map")
//                    Text("Map")
//                }
//            
            ListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }
            
            ComparisonView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Compare")
                }
        }
    }
}

#Preview {
    MainView()
}
