import SwiftUI
import CoreLocation


struct ContentView: View {
    @StateObject private var viewModel = LocationViewModel()
    @State private var locationInput: String = ""

    var body: some View {
        VStack {
            // Text Field for user input
            TextField("Enter a location or city", text: $locationInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Button to fetch current location
            Button(action: {
//                viewModel.fetchCurrentLocation()
                switch CLLocationManager.authorizationStatus() {
                        case .notDetermined, .restricted, .denied:
                            print("Location access not granted")
                        case .authorizedWhenInUse, .authorizedAlways:
                    viewModel.fetchCurrentLocation()
                        @unknown default:
                            print("Unknown authorization status")
                        }
            }) {
                Text("Get Current Location")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Display current location
            Text(viewModel.currentLocation)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
