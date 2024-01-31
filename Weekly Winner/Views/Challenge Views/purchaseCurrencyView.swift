//
//  purchaseCurrencyView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/22/24.
//

import SwiftUI
import UIKit
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
    
    @State var depositAmountString: String = ""
    @State var withdrawlAmount: Int = 0

    var body: some View {
        
        ZStack {
            K.finalColor.backgroundBlue
            
            if allowedStates.contains(locationViewModel.state) {
                VStack{

                    
                    VStack (spacing: 4){
                        HStack (spacing: 0){
                            Button(action: {
                                if timeFrame != "Deposit" {
                                    timeFrame = "Deposit"
                                }
                            }) {
                                Text("Deposit")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 26))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 35, alignment: .center)
                                    .cornerRadius(5)
                            }
                            
                            Button(action: {
                                if timeFrame == "Deposit" {
                                    timeFrame = "Withdraw"
                                }
                                
                            }) {
                                Text("Withdraw")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 26))
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
                        
                        if timeFrame == "Deposit" {
                            depositView()
                        } else {
                            withdrawalView()
                        }

                    }
                    Spacer()
                }.padding(.top, 10)
                    .background(K.finalColor.backgroundBlue)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
            } else {
                Text("This page is not available in your location.")
                Text(locationViewModel.state)
            }
        }
    }
}

struct depositView: View {
    @State private var value = 0 //in cents
    
    private var numberFormatter: NumberFormatter
    
    init(numberFormatter: NumberFormatter = NumberFormatter()) {
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }
    var body: some View {
        ZStack {
            HStack {
                Image("poolBuck")
                    .resizable()
                    .frame(width: 65, height: 65)
                    .padding(.leading, 15)
                Spacer()
            }
            
            CurrencyTextField(numberFormatter: numberFormatter, value: $value)
                .padding(.trailing, 15)
                
        }.frame(width: 300, height: 75)
            .background(K.finalColor.cardBlue)
            .cornerRadius(7.5)
            .padding(.bottom, 25)
            .padding(.top, 15)
            .onAppear() {
                value = 0
            }
            



        if value >= 100 && value < 99999 {
            Link(destination: URL(string: "https://wppaypal-zuj4eapv2q-uc.a.run.app/?userID=\(StaticUserData.shared.currentUser.id!)&amount=\(value/100)")!) {
                VStack(spacing: 10) {
                    Image("venmoButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .cornerRadius(10)
                    Image("paypalButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .cornerRadius(10)
                    
                    Image("withCardButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .cornerRadius(5)
                }
            }
        } else {
            VStack(spacing: 10) {
                Image("venmoButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .cornerRadius(10)
                Image("paypalButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .cornerRadius(10)
                
                Image("withCardButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .cornerRadius(5)
            }
        }
        
        if value < 100 {
            Text("Minimum purchase of $1.00")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                .foregroundColor(.red)
                .frame(width: 300)
                .padding(.top, 25)
        }
    }
}

struct withdrawalView: View {
    var body: some View {
        Text("Here")
    }
}




class CurrencyUITextField: UITextField {
    
    @Binding private var value: Int
    private let formatter: NumberFormatter
    
    init(formatter: NumberFormatter, value: Binding<Int>) {
        self.formatter = formatter
        self._value = value
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(resetSelection), for: .allTouchEvents)
        keyboardType = .numberPad
        textAlignment = .right
        sendActions(for: .editingChanged)
    }
    
    override func deleteBackward() {
        text = textValue.digits.dropLast().string
        sendActions(for: .editingChanged)
    }
    
    private func setupViews() {
        textColor = .white // Change to desired color
        font = UIFont(name: K.customFonts.lexendDecaLight, size: 50) // Specify your custom font name and size
        tintColor = .clear
    }
    
    @objc private func editingChanged() {
        let newValue = decimal
        let newIntValue = Int((newValue as NSDecimalNumber).doubleValue * 100)
        
        // Check if the new value is greater than 99999 (999.99 in your currency format)
        if newIntValue <= 99999 {
            text = currency(from: newValue)
            resetSelection()
            value = newIntValue
        } 
        else {
            // If the value is greater, reset it to the max
            text = currency(from: Decimal(99999) / 100)
            resetSelection()
            value = 99999
        }
    }

    
    @objc private func resetSelection() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }
    
    private var textValue: String {
        return text ?? ""
    }

    private var doubleValue: Double {
      return (decimal as NSDecimalNumber).doubleValue
    }

    private var decimal: Decimal {
      return textValue.decimal / pow(10, formatter.maximumFractionDigits)
    }
    
    private func currency(from decimal: Decimal) -> String {
        return formatter.string(for: decimal) ?? ""
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter (\.isWholeNumber) }
}

extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}

#Preview {
    purchaseCurrencyView()
}


struct CurrencyTextField: UIViewRepresentable {
    
    typealias UIViewType = CurrencyUITextField
    
    let numberFormatter: NumberFormatter
    let currencyField: CurrencyUITextField
    
    init(numberFormatter: NumberFormatter, value: Binding<Int>) {
        self.numberFormatter = numberFormatter
        currencyField = CurrencyUITextField(formatter: numberFormatter, value: value)
    }
    
    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyField
    }
    
    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}
