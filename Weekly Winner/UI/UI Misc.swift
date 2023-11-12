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
    static func backgroundForBetResult(_ result: BetResult) -> Color {
        switch result {
        case .notStarted: return K.finalColor.backgroundBlue
        case .inAction: return K.finalColor.potentialOrange
        case .loss: return K.finalColor.deleteRed
        case .win: return K.finalColor.winningGreen
        case .forcedLoss: return K.lightRed
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
    @Published var timeRemaining: String = ""
    private var timer: AnyCancellable?

    init() {
        startTimer()
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimeRemaining()
            }
    }

    private func updateTimeRemaining() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let now = Date()
        let nextSunday = calendar.nextDate(after: now, matching: DateComponents(hour: 0, weekday: 2), matchingPolicy: .nextTime)!
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: nextSunday)
        timeRemaining = String(format: "%d : %02d : %02d : %02d", components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }
}

