import SwiftUI
import CoreLocation

class LocationViewModel: ObservableObject {
    @Published var currentLocation: String = "Current Location: Unknown"
    @Published var currentLatitude: Double = 0.0
    @Published var currentLongitude: Double = 0.0

    private var locationManager = CLLocationManager()
    private var locationDelegate: LocationDelegate?

    init() {
        locationDelegate = LocationDelegate { location in
            if let location = location {
                DispatchQueue.main.async {
                    self.currentLatitude = location.coordinate.latitude
                    self.currentLongitude = location.coordinate.longitude
                    self.currentLocation = "Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)"
                }
            } else {
                DispatchQueue.main.async {
                    self.currentLocation = "Current Location: Unable to retrieve location"
                }
            }
        }
        locationManager.delegate = locationDelegate
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchCurrentLocation() {
        locationManager.requestLocation()
    }
}

// Location Delegate
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((CLLocation?) -> Void)?
    
    init(onLocationUpdate: @escaping (CLLocation?) -> Void) {
        self.onLocationUpdate = onLocationUpdate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update locations: \(locations)")

        if let location = locations.last {
            onLocationUpdate?(location)
        }
        manager.stopUpdatingLocation() // Stop updates to save battery
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")

        onLocationUpdate?(nil) // Handle error
    }
}
