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
    
    @State var timeFrame = "Deposit"
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
                VStack{
                    VStack (spacing: 4){
                        HStack (spacing: 0){
                            Button(action: {
                                //viewModel.canGetHistoricalData = false
                                if timeFrame != "Deposit" {
                                    timeFrame = "Deposit"
                                    
                                }
                                
                            }) {
                                //Text(viewModel.userTickets[self.selectedGroup-1].groupName)
                                Text("Deposit")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 35, alignment: .center)
                                //.background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }
                            
                            Button(action: {
                                //viewModel.canGetHistoricalData = false
                                if timeFrame == "Deposit" {
                                    
                                    timeFrame = "Withdrawl"
                                    
                                    
                                }
                                
                            }) {
                                Text("Withdrawl")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 35, alignment: .center)
                                    .cornerRadius(5)
                            }
                        }
                        Rectangle()
                            .fill(Color.white) // Sets the rectangle's fill color to white
                            .frame(width: 120, height: 3)
                            .cornerRadius(1) // Apply rounded corners
                            .offset(x: timeFrame == "Deposit" ? -75 : 75, y: 0)
                            .animation(.easeInOut(duration: 0.35))
                        
                    }
                }.padding(.top, 23)
                    .background(K.finalColor.backgroundBlue)
            } else {
                Text("This page is not available in your location.")
                Text(locationViewModel.state)
            }
        }
}




#Preview {
    purchaseCurrencyView()
}
