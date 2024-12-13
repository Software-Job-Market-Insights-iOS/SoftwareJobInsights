import SwiftUI
import MapKit

struct MapContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var showFilters = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapView(cities: mainViewModel.filteredCities, filterType: mainViewModel.selectedFilter)
            
            
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
                            Button(action: { mainViewModel.selectedFilter = filter }) {
                                HStack {
                                    Text(filter.title)
                                    if mainViewModel.selectedFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        Text("Number of Cities: \(mainViewModel.numberOfCities)")
                            .font(.headline)
                        Slider(value: .init(
                            get: { Double(mainViewModel.numberOfCities) },
                            set: { mainViewModel.numberOfCities = Int($0) }
                        ), in: 5...50, step: 5)
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
    let city: City
    let filterType: FilterType
    @State private var isHovered = false
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            Image(systemName: filterType.icon)
                .foregroundColor(mainViewModel.colorViewModel.getColor(for: filterType, city: city))
                .font(.title)
                .onHover { hovering in
                    withAnimation {
                        isHovered = hovering
                    }
                }
                .onTapGesture {
                    showDetails.toggle()
                }
            
            if isHovered {
                VStack(spacing: 2) {
                    Text(city.name)
                        .font(.caption)
                    Text(mainViewModel.getFormattedValue(for: filterType, from: city))
                        .font(.caption2)
                }
                .padding(4)
                .background(.white.opacity(0.9))
                .cornerRadius(4)
            }
        }
        .sheet(isPresented: $showDetails) {
            CityDetailView(city: city)
        }
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
    let cities: [City]
    let filterType: FilterType
    
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
                    CustomAnnotation(city: city, filterType: filterType)
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
