import SwiftUI
import CoreLocation
import Foundation
import GoogleGenerativeAI


struct ContentView: View {
    @StateObject private var viewModel = LocationViewModel()
    @State private var locationInput: String = ""
    @State private var selectedHours: Int = 1 // Local state variable for hours
    @State private var placesOfInterest: [String] = [] // Array to hold places of interest



    var body: some View {
        VStack {
            // Text Field for user input
            TextField("Enter a location or city", text: $locationInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // a picker to select the number of hours to plan the tour for
            Picker("Number of hours", selection: $selectedHours) {
                Text("1").tag(1)
                Text("2").tag(2)
                Text("3").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Button to ask LLM for a tour plan
            Button(action: {
                Task {
                    await askLLMforTourPlan(city: locationInput, hours: selectedHours)
                }
            }) {
                Text("Get Tour Plan")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

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


    // Function to ask LLM for a tour plan
    private func askLLMforTourPlan(city: String, hours: Int) async {
        print(city)
        let apiKey = "gemini key"

       let prompt = "Please suggest a tour plan for \(city) for \(hours) hours."
        
        let generativeModel =
          GenerativeModel(
            // Specify a Gemini model appropriate for your use case
            name: "gemini-1.5-flash",
            // Access your API key from your on-demand resource .plist file (see "Set up your API key"
            // above)
            apiKey: apiKey
          )

        do {
            let response = try await generativeModel.generateContent(prompt)
            if let text = response.text {
          print(text)
            }
        } catch {
            print("Error: \(error)")
        }
    }
        
}

#Preview {
    ContentView()
}
