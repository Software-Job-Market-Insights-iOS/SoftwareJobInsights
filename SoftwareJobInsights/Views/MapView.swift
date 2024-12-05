import SwiftUI
import MapKit
import CoreLocation

struct CityAnnotation: Identifiable {
    let id = UUID()
    let cityName: String
    let coordinate: CLLocationCoordinate2D
}

struct MapView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )
    
    @State private var annotations: [CityAnnotation] = []
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                VStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                    
                    Text(annotation.cityName)
                        .font(.caption)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(4)
                }
            }
        }
        .task {
            await loadCityCoordinates()
        }
    }
    
    func loadCityCoordinates() async {
        let geocoder = CLGeocoder()
        var newAnnotations: [CityAnnotation] = []
        
        for cityName in mainViewModel.getAllCityNames() {
            do {
                print(cityName)
                let searchString = "\(cityName), USA"
                let placemarks = try await geocoder.geocodeAddressString(cityName)
                
                if let firstPlace = placemarks.first,
                   let location = firstPlace.location {
                    let annotation = CityAnnotation(
                        cityName: cityName,
                        coordinate: location.coordinate
                    )
                    newAnnotations.append(annotation)
                }
                // Add a small delay to avoid hitting rate limits
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            } catch {
                print("Error geocoding \(cityName): \(error)")
            }
        }
        
        // Update annotations on the main thread
        await MainActor.run {
            annotations = newAnnotations
        }
    }
}

#Preview {
    MapView()
        .environmentObject(MainViewModel())
}
