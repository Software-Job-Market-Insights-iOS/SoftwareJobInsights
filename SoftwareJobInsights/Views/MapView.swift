import SwiftUI
import MapKit


struct MapContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var selectedFilter: FilterType = .unadjustedSalary
    @State private var numberOfCities: Int = 30
    @State private var showFilters = false
    
    enum FilterType: Identifiable {
        case adjustedSalary
        case unadjustedSalary
        case softwareJobs
        case homePrice
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .adjustedSalary: return "Adjusted Salary"
            case .unadjustedSalary: return "Unadjusted Salary"
            case .softwareJobs: return "Quantity of Software Jobs"
            case .homePrice: return "Home Price"
            }
        }
    }
    
    var filteredCities: [City] {
        switch selectedFilter {
        case .adjustedSalary:
            return mainViewModel.getTopCitiesByAdjustedSalary(num: numberOfCities)
        case .unadjustedSalary:
            return mainViewModel.getTopCitiesByUnadjustedSalary(num: numberOfCities)
        case .softwareJobs:
            return mainViewModel.getTopCitiesBySoftwareJobs(num: numberOfCities)
        case .homePrice:
            return mainViewModel.getTopCitiesByMedianHomePrice(num: numberOfCities)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapView(cities: filteredCities)
            
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
                        
                        ForEach([FilterType.adjustedSalary,
                                .unadjustedSalary,
                                .softwareJobs,
                                .homePrice]) { filter in
                            Button(action: { selectedFilter = filter }) {
                                HStack {
                                    Text(filter.title)
                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Text("Number of Cities: \(numberOfCities)")
                            .font(.headline)
                        Slider(value: .init(
                            get: { Double(numberOfCities) },
                            set: { numberOfCities = Int($0) }
                        ), in: 5...50, step: 5)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// Modified MapView to accept cities as parameter
struct MapView: View {
    let cities: [City]
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    ))
    
    var body: some View {
        Map(position: $position) {
            ForEach(cities) { city in
                Annotation(city.name, coordinate: CLLocationCoordinate2D(
                    latitude: Double(city.latitude),
                    longitude: Double(city.longitude)
                )) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        
                        Text(city.name)
                            .font(.caption)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .mapStyle(.standard)
    }
}

#Preview {
    MapContainer()
        .environmentObject(MainViewModel())
}
