import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of US
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: mainViewModel.getAllCityNamesLocId()) { city in
            MapAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: Double(city.lat),
                longitude: Double(city.long)
            )) {
                VStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                    
                    Text(city.cityName)
                        .font(.caption)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(4)
                }
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(MainViewModel())
}
