//
//  purchaseCurrencyView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/22/24.
//

import SwiftUI
import CoreLocation

// Updated LocationViewModel
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    @Published var speed: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var log: String = ""
    @Published var state: String = ""
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
}
    
    extension LocationViewModel {
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .notDetermined:
                log = "Location authorization not determined"
            case .restricted:
                log = "Location authorization restricted"
            case .denied:
                log = "Location authorization denied"
            case .authorizedAlways:
                manager.requestLocation()
                log = "Location authorization always granted"
            case .authorizedWhenInUse:
                manager.startUpdatingLocation()
                log = "Location authorization when in use granted"
            @unknown default:
                log = "Unknown authorization status"
            }
        }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                locations.forEach { location in
                    self.speed = location.speed
                    self.latitude = location.coordinate.latitude
                    self.longitude = location.coordinate.longitude

                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location) { placemarks, error in
                        if let placemark = placemarks?.first, let adminArea = placemark.administrativeArea {
                            self.state = adminArea
                        }
                    }
                }
            }
}

// Updated purchaseCurrencyView
struct purchaseCurrencyView: View {
    @ObservedObject private var locationViewModel = LocationViewModel()
    
    let allowedStates = ["AK", "AZ", "AR", "CA", "CO", "FL", "GA", "IL", "IN",
                  "KS","KY","MD","MA","MI","MN","NE","NM","NY",
                  "NC","ND","OK","OR","RI",
                  "SC","SD","TX",
                  "UT",
                  "VT",
                  "VA",
                  "WI",
                  "WY","DC"]

    
    var body: some View {
            if allowedStates.contains(locationViewModel.state) {
                ZStack {
                    VStack {
                        Text("Betting is allowed in your state. May the odds be in your favor.")
                        Text(String(format: "Speed: %.2f m/s", locationViewModel.speed))
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .background(locationViewModel.speed < 1.0 ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)

                        Text("Latitude: \(locationViewModel.latitude)")
                        Text("Longitude: \(locationViewModel.longitude)")
                            .padding()
                            .frame(maxWidth: .infinity)

                        Text(locationViewModel.log)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
            } else {
                Text("This page is not available in your location.")
                Text(locationViewModel.state)
            }
        }
}




#Preview {
    purchaseCurrencyView()
}
