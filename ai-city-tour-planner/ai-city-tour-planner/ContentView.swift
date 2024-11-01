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
        let apiKey = ""
       
        let prompt = """
        Provide a JSON array of points of interest for a \(hours)-hour round walking tour in \(city) with the following structure for each location:
        {
          "name": "Location Name",
          "latitude": 00.000000,
          "longitude": 00.000000,
          "type": "category of attraction",
          "estimated_visit_time_minutes": 15,
          "walking_distance_from_previous_location_meters": 200
        }

        Constraints:
        - Total tour must be a round trip, starting and ending at the same point
        - First and last locations must be the same
        - Total tour should match exactly \(hours) hours (including walking time)
        - Select attractions that can be comfortably visited within the time frame
        - Optimize for a logical walking route with minimal backtracking
        - Prioritize most significant attractions
        - Ensure walking distances between locations are reasonable
        - Do not include any additional text or explanation
        """
        
        let generativeModel =
          GenerativeModel(
            // Specify a Gemini åmodel appropriate for your use case
            name: "gemini-1.5-flash",
            // Access your API key from your on-demand resource .plist file (see "Set up your API key"
            // above)
            apiKey: apiKey
          )

        do {
            let response = try await generativeModel.generateContent(prompt)
            if let text = response.text {
                // Remove markdown formatting (backticks and 'json' label)
                let cleanedText = text
                    .replacingOccurrences(of: "```json", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                print(cleanedText)
                    
                // Parse the JSON response
                if let data = cleanedText.data(using: .utf8) {
                    do {
                        let places = try JSONDecoder().decode([Place].self, from: data)
                        // Create a Google Maps URL
                        let googleMapsURL = createGoogleMapsURL(from: places)
                        print(googleMapsURL)

                        // Open the Google Maps app
                        if let url = URL(string: googleMapsURL) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
        
}

// Define a struct to match the JSON structure
struct Place: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    // Add other fields if necessary
}

// Function to create a Google Maps URL
func createGoogleMapsURL(from places: [Place]) -> String {
    let baseURL = "https://www.google.com/maps/dir/?api=1"
    let waypoints = places.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
    return "\(baseURL)&waypoints=\(waypoints)"
}

#Preview {
    ContentView()
}
