import SwiftUI
import MapKit

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
        case .softwareJobs: return "Software Jobs"
        case .homePrice: return "Home Price"
        }
    }
    
    var icon: String {
        switch self {
        case .adjustedSalary: return "dollarsign.circle.fill"
        case .unadjustedSalary: return "banknote.fill"
        case .softwareJobs: return "laptopcomputer"
        case .homePrice: return "house.fill"
        }
    }
    
    struct ColorConfig {
        let lowColor: (Double, Double, Double)
        let highColor: (Double, Double, Double)
        let minValue: Double
        let maxValue: Double
    }

    var colorConfig: ColorConfig {
        switch self {
        case .adjustedSalary:
            return ColorConfig(
                lowColor: (0.7, 0.9, 0.7),   // Light green
                highColor: (0, 0.6, 0),      // Dark green
                minValue: 80_000,
                maxValue: 200_000
            )
        case .unadjustedSalary:
            return ColorConfig(
                lowColor: (0.7, 0.7, 1.0),   // Light blue
                highColor: (0, 0, 0.8),      // Dark blue
                minValue: 100_000,
                maxValue: 250_000
            )
        case .softwareJobs:
            return ColorConfig(
                lowColor: (1.0, 0.7, 1.0),   // Light purple
                highColor: (0.5, 0, 0.5),    // Dark purple
                minValue: 1_000,
                maxValue: 50_000
            )
        case .homePrice:
            return ColorConfig(
                lowColor: (1.0, 0.9, 0.7),   // Light orange
                highColor: (0.8, 0.4, 0),    // Dark orange
                minValue: 200_000,
                maxValue: 1_000_000
            )
        }
    }

    func color(for value: Double) -> Color {
        let config = colorConfig
        
        // Normalize between 0 and 1 using predefined ranges
        let normalized = (value - config.minValue) / (config.maxValue - config.minValue)
        let clamped = max(0, min(1, normalized))  // Ensure value is between 0 and 1
        
        // Interpolate between the two colors using tuples
        let r = config.lowColor.0 + (config.highColor.0 - config.lowColor.0) * clamped
        let g = config.lowColor.1 + (config.highColor.1 - config.lowColor.1) * clamped
        let b = config.lowColor.2 + (config.highColor.2 - config.lowColor.2) * clamped
        
        return Color(red: r, green: g, blue: b)
    }
    
    func getValue(from city: City) -> Double {
        switch self {
        case .adjustedSalary: return city.meanSalaryAdjusted
        case .unadjustedSalary: return city.meanSalaryUnadjusted
        case .softwareJobs: return Double(city.quantitySoftwareJobs)
        case .homePrice: return Double(city.medianHomePrice)
        }
    }
    
    func formatValue(_ value: Double) -> String {
        switch self {
        case .adjustedSalary, .unadjustedSalary, .homePrice:
            return "$\(Int(value).formatted())"
        case .softwareJobs:
            return "\(Int(value).formatted())"
        }
    }
}

struct MapContainer: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var selectedFilter: FilterType = .unadjustedSalary
    @State private var numberOfCities: Int = 30
    @State private var showFilters = false

    
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
            MapView(cities: filteredCities, filterType: selectedFilter)
            
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

struct CustomAnnotation: View {
    let city: City
    let filterType: FilterType
    @State private var isHovered = false
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            Image(systemName: filterType.icon)
                .foregroundColor(filterType.color(for: filterType.getValue(from: city)))
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
                    Text(filterType.formatValue(filterType.getValue(from: city)))
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
