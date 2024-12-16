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
                            Button(action: { mainViewModel.currentFilter = filter }) {
                                HStack {
                                    Text(filter.title)
                                    if mainViewModel.isCurrentFilter(filter) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        if mainViewModel.isCompanyCityMode {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Search Companies:")
                                    .font(.headline)
                                
                                TextField("Enter company name...", text: $mainViewModel.companySearchQuery)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocorrectionDisabled()
                                
                                ScrollView {
                                    LazyVStack(alignment: .leading) {
                                        ForEach(mainViewModel.filteredCompanyNames, id: \.self) { companyName in
                                            Button(action: { mainViewModel.selectedCompany = companyName }) {
                                                HStack {
                                                    Text(companyName)
                                                    Spacer()
                                                    if mainViewModel.selectedCompany == companyName {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                                .padding(.vertical, 4)
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                            }
                        }
                        else {
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
                    Label(mainViewModel.isCompanyCityMode ? mainViewModel.selectedCompany : "City Mode",
                          systemImage: mainViewModel.isCompanyCityMode ? "building.2" : "map")
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
    let filterType: MapLocFilterType
    @State private var isHovered = false
    @State private var showDetails = false
    
    var body: some View {
        Image(systemName: filterType.icon)
            .foregroundColor(mainViewModel.colorViewModel.getColor(for: filterType, mapLoc: mapLocation))
            .font(.title)
            .onTapGesture {
                switch mapLocation {
                case .city(let city):
                    print("setting selected location")
                    mainViewModel.selectedLocation = .city(city)
                case .companyCity(let companyCity):
                    mainViewModel.selectedLocation = .companyCity(companyCity)
                }
            }
    }
}


struct MapView: View {
    let currentLocations: [MapLocation]
    let filterType: MapLocFilterType
    
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
