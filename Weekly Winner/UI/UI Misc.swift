//
//  UI Misc.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 7/7/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore



struct K {
    static let backgroundBlue = Color(hex: "#0D3B66")
    static let cardBackground = Color(hex: "#F4F1DE")
    static let textBlack = Color(hex: "#000000")
    static let accentRed = Color(hex: "#E63946")
    static let veryLightGray = Color(hex: "F2F2F2")
    static let veryLightBlue = Color(hex: "#CCDDFF")
    static let darkBlue = Color(hex: "#062F4F")
    static let darkGreen = Color(hex: "#064F2F")
    static let lightGreen = Color(hex: "#CCFFCC")
    static let lightRed = Color(hex: "#FFCCCC")
    static let lightYellow = Color(hex: "#FFFFCC")
    static let midnightBlue = Color(hex: "#1D3557")
    static let steelBlue = Color(hex: "#457B9D")
    static let powderBlue = Color(hex: "#A8DADC")
    static let mediumAquamarine = Color(hex: "#2A9D8F")
    static let sandyBrown = Color(hex: "#E9C46A")
    static let sandyTan = Color(hex: "#F4A261")
    static let burntSienna = Color(hex: "#E76F51")
    static let charcoal = Color(hex: "#264653")
    static let jungleGreen = Color(hex: "#2B9348")
    static let teaGreen = Color(hex: "#99D98C")
    static let lemonYellow = Color(hex: "#FDE74C")
    static let coralPink = Color(hex: "#FF6E6E")
    static let independence = Color(hex: "#5E6472")
    static let tomatoRed = Color(hex: "#E63946")
    static let mintCream = Color(hex: "#F1FAEE")
    static let lightCyan = Color(hex: "#A8DADC")
    static let cadetBlue = Color(hex: "#457B9D")
    static let darkMidnightBlue = Color(hex: "#1D3557")
    static let darkCyan = Color(hex: "#1A535C")
    static let lightMoneyGreen = Color(hex: "#30DF7A")
    static let averageGray = Color(hex: "#808080")
    
    struct finalColor {
        static let titleBlue = Color(hex: "#4F91FF")
        static let backgroundBlue = Color(hex: "#050C42")
        static let cardBlue = Color(hex: "#202456")
        static let tabSelectedBlue = Color(hex: "#75B5FB")
        
//        static let titleBlue = Color(hex: "#4F91FF")
//        static let backgroundBlue = Color(hex: "#E8F5E9")
//        static let cardBlue = Color(hex: "#42A5F5")
//        static let tabSelectedBlue = Color(hex: "#75B5FB")
        
        
        static let potentialOrange = Color(hex: "#FF8D07")
        static let winningGreen = Color(hex: "#3EDC06")
        static let textWhite = Color(hex: "#FFFFFF")
        static let deleteRed = Color(hex: "#DC3545")
        static let otherPurple = Color(hex: "#9C63FB")
        static let otherBeige = Color(hex: "#F8A680")
        static let blueGray = Color(hex: "#607D8B")
    }
    
    struct finalUIColor {
        static let tabSelectedBlue = UIColor(hex: "#75B5FB")
    }
    
    struct imgNames {
        static let alertCircle      = "ic_alert_circle"
        static let info             = "ic_info"
        static let success          = "ic_succes"
        static let checkCircle      = "ic_check_circle"
        static let warning          = "ic_warning"
    }

    struct appButtonTitle {
        static let ok               = "Update"
        static let cancel           = "Cancel"
        static let signOut = "Sign Out"
        static let leaveGroup = "Leave"
    }
    
    struct customFonts {
        static let juraRegular = "Jura-Regular"
        static let poppinsLight = "Poppins-Light"
        static let poppinsMedium = "Poppins-Medium"
        static let poppinsRegular = "Poppins-Regular"
        static let lexendDecaMedium = "LexendDeca-Medium"
        static let lexendDecaSB = "LexendDeca-SemiBold"
        static let lexendDecaLight = "LexendDeca-Light"
    }

}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct popUpPill: View {
    var body: some View {
        Color.white
            .opacity(0.2)
            .frame(width: 30, height: 6)
            .clipShape(Capsule())
            .padding(.top, 15)
            .padding(.bottom, 10)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
}


extension Color {
    static func cardColorForBetResult(_ result: BetResult) -> Color {
        switch result {
        case .notStarted: return K.finalColor.backgroundBlue
        case .inAction: return K.finalColor.potentialOrange
        case .loss: return K.finalColor.deleteRed
        case .win: return K.finalColor.winningGreen
        case .forcedLoss: return K.lightRed
        case .push: return K.averageGray
        // add other cases as needed
        }
    }
    
    static func cardBackgroundForBetResult(_ result: BetResult) -> Color {
        let opacity = 0.65
        switch result {
        case .notStarted: return K.finalColor.cardBlue
        case .inAction: return K.finalColor.potentialOrange.opacity(opacity)
        case .loss: return K.finalColor.deleteRed.opacity(opacity)
        case .win: return K.finalColor.winningGreen.opacity(opacity)
        case .forcedLoss: return K.lightRed.opacity(opacity)
        case .push: return K.averageGray.opacity(opacity)
        // add other cases as needed
        }
    }
    
}


struct formatDateMMMDHMM {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm"
        formatter.timeZone = TimeZone(abbreviation: "EST") // Or whatever timezone the date is in
        return formatter
    }()

    static func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

struct formatDateEMMMDHMM {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, h:mm a"
        formatter.timeZone = TimeZone(abbreviation: "EST") // Or whatever timezone the date is in
        return formatter
    }()

    static func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}


func formatDateMMDDYY(from timestamp: Timestamp) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yy" // Added hours and minutes to the format
    
    return formatter.string(from: timestamp.dateValue())
}


import Foundation
import Combine

class CountdownTimer: ObservableObject {
    @Published var weekTimeRemaining: String = ""
    @Published var dayTimeRemaining: String = ""
    private var weekTimer: AnyCancellable?
    private var dayTimer: AnyCancellable?

    init() {
        startDayTimer()
       startWeekTimer()
    }

    private func startDayTimer() {
        weekTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDayTimeRemaining()
            }
    }
    private func startWeekTimer() {
        dayTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateWeekTimeRemaining()
            }
    }
    
//    var calendar = Calendar.current
//       calendar.timeZone = TimeZone(identifier: "America/New_York")!
//       let now = Date()

      

    private func updateWeekTimeRemaining() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let now = Date()

            let nextSunday = calendar.nextDate(after: now, matching: DateComponents(hour: 0, weekday: 2), matchingPolicy: .nextTime)!
            let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: nextSunday)

            // Adjusted string formatting to include d, h, m, s
            weekTimeRemaining = String(format: "%dd : %02dh : %02dm : %02ds",
                                   components.day ?? 0,
                                   components.hour ?? 0,
                                   components.minute ?? 0,
                                   components.second ?? 0)

    }
    
    private func updateDayTimeRemaining() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let now = Date()

            // Calculate the start of the next day (midnight)
            guard let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0), matchingPolicy: .nextTime) else {
                return
            }

            let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: nextMidnight)

            // Adjusted string formatting to include h, m, s
            dayTimeRemaining = String(format: "%02dh : %02dm : %02ds",
                                   components.hour ?? 0,
                                   components.minute ?? 0,
                                   components.second ?? 0)


    }
    
}


extension String {
    func containsEmoji() -> Bool {
        for scalar in self.unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Regional country flags
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F018...0x1F270, // Various asian characters
                 0x238C...0x2454,   // Misc items
                 0x20D0...0x20FF:   // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }
}

struct CustomFontModifier: ViewModifier {
    var size: CGFloat
    var color: Color

    func body(content: Content) -> some View {
        content
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: size))
            .foregroundColor(color)
    }
}

extension View {
    func lexMedCustom(_ size: CGFloat, color: Color) -> some View {
        modifier(CustomFontModifier(size: size, color: color))
    }
}



enum CommodityColor {
    case gold
    case silver
    case platinum
    case bronze

    var colors: [Color] {
        switch self {
        case .gold:
            return [Color(hex: "#DBB400"),
                    Color(hex: "#EFAF00"),
                    Color(hex: "#F5D100"),
                    Color(hex: "#F5D100"),
                    Color(hex: "#D1AE15"),
                    Color(hex: "#DBB400"),
            ]

        case .silver:
            return [Color(hex: "#70706F"),
                    Color(hex: "#7D7D7A"),
                    Color(hex: "#B3B6B5"),
                    Color(hex: "#8E8D8D"),
                    Color(hex: "#B3B6B5"),
                    Color(hex: "#A1A2A3"),
            ]

        case .platinum:
            return [Color(hex: "#000000"),
                    Color(hex: "#444444"),
                    Color(hex: "#000000"),
                    Color(hex: "#444444"),
                    Color(hex: "#111111"),
                    Color(hex: "#000000"),
            ]

        case .bronze:
            return [Color(hex: "#804A00"),
                    Color(hex: "#9C7A3C"),
                    Color(hex: "#B08D57"),
                    Color(hex: "#895E1A"),
                    Color(hex: "#804A00"),
                    Color(hex: "#B08D57"),
            ]
        }
    }

    var linearGradient: LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: self.colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

func isWholeNumber(_ value: Double) -> Bool {
    return value.truncatingRemainder(dividingBy: 1) == 0
}


func customizeTicketFormat(_ a: Int,_ b: Int,_ c: Int,_ d: Int,_ e: Int) -> [Int] {
    var ticketFormatArr: [Int] = []
    for _ in 0..<a {
        ticketFormatArr.append(1)
    }
    for _ in 0..<b {
        ticketFormatArr.append(2)
    }
    for _ in 0..<c {
        ticketFormatArr.append(3)
    }
    for _ in 0..<d {
        ticketFormatArr.append(4)
    }
    for _ in 0..<e {
        ticketFormatArr.append(5)
    }
    return ticketFormatArr
}

struct CustomStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let title: String
    
    var body: some View {
        HStack {
            Text("\(title): \(value)")
                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16).weight(.light))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                if value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(5)
            }
          
            Button(action: {
                if value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(5)
            }
        }.padding(.vertical, 5)

    }
}

struct CustomStepper2: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let title: String
    
    var body: some View {
        VStack {
            Text("\(value) \(title)")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 30))
                .foregroundColor(.white)
            
            HStack (spacing: 15) {
                Spacer()
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 60)
                        .background(K.finalColor.titleBlue.opacity(0.7))
                        .cornerRadius(5)
                }
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 60)
                        .background(K.finalColor.titleBlue.opacity(0.7))
                        .cornerRadius(5)
                }
                Spacer()
            }
            
        }.frame(height: 150).background(K.finalColor.cardBlue).cornerRadius(7.5)
    
    }
}
