import SwiftUI
import MapKit

struct MapContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showFilters = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapView(currentLocations: mainViewModel.getCurrentLocations(), filterType: mainViewModel.currentFilter)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Button(action: { showFilters.toggle() }) {
                    Label(showFilters ? "Hide Filters" : "Show Filters",
                          systemImage: showFilters ? "chevron.up" : "chevron.down")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                
                if showFilters {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter By:")
                            .font(.headline)
                        
                        ForEach(mainViewModel.getFilterTypes()) { filter in
                            Button(action: { mainViewModel.setFilter(filter) }) {
                                HStack {
                                    Text(filter.title)
                                    if mainViewModel.isCurrentFilter(filter) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        if !mainViewModel.isCompanyMode {
                            Text("Number of Cities: \(mainViewModel.numOfCitiesCity)")
                                .font(.headline)
                            Slider(value: .init(
                                get: { Double(mainViewModel.numOfCitiesCity) },
                                set: { newValue in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        mainViewModel.numOfCitiesCity = Int(newValue)
                                    }
                                }
                            ), in: 5...30, step: 5)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            .padding()
            
            VStack {
                Button(action: { mainViewModel.toggleMode() }) {
                    Label(mainViewModel.isCompanyMode ? "Company Mode" : "City Mode",
                          systemImage: mainViewModel.isCompanyMode ? "building.2" : "map")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct CustomAnnotation: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    let mapLocation: MapLocation
    let filterType: FilterType
    @State private var isHovered = false
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            Image(systemName: filterType.icon)
                .foregroundColor(mainViewModel.colorViewModel.getColor(for: filterType, mapLoc: mapLocation))
                .font(.title)
                .onHover { hovering in
                    withAnimation {
                        isHovered = hovering
                    }
                }
                .onTapGesture {
                    showDetails.toggle()
                }
        }
//        .sheet(isPresented: $showDetails) {
//            CityDetailView(city: city)
//        }
    }
}

struct CityDetailView: View {
    let city: City
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Salary Information") {
                    LabeledContent("Adjusted Salary", value: "$\(Int(city.meanSalaryAdjusted).formatted())")
                    LabeledContent("Unadjusted Salary", value: "$\(Int(city.meanSalaryUnadjusted).formatted())")
                }
                
                Section("Housing") {
                    LabeledContent("Median Home Price", value: "$\(city.medianHomePrice.formatted())")
                    LabeledContent("Average Rent", value: "$\(Int(city.rentAverage).formatted())")
                }
                
                Section("Jobs & Economy") {
                    LabeledContent("Software Jobs", value: city.quantitySoftwareJobs.formatted())
                    LabeledContent("Cost of Living Index", value: String(format: "%.1f", city.costOfLivingAverage))
                }
                
                Section("Demographics") {
                    LabeledContent("Population", value: city.population.formatted())
                    LabeledContent("Density", value: "\(city.density.formatted())/sq mi")
                }
            }
            .navigationTitle(city.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct MapView: View {
    let currentLocations: [MapLocation]
    let filterType: FilterType
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    ))
    
    var body: some View {
        Map(position: $position) {
            ForEach(currentLocations) { curLoc in
                Annotation(curLoc.name, coordinate: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(curLoc.coordinate.latitude),
                    longitude: CLLocationDegrees(curLoc.coordinate.longitude)
                )) {
                    CustomAnnotation(mapLocation: curLoc, filterType: filterType)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: [], showsTraffic: false))
    }
}

#Preview {
    MapContainer()
        .environmentObject(MainViewModel())
}
