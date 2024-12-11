import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of US
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    ))
    
    var body: some View {
        Map(position: $position) {
            ForEach(mainViewModel.getTopCitiesByUnadjustedSalary(num: 30)) { city in
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
    MapView()
        .environmentObject(MainViewModel())
}
