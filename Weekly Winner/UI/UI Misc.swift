//
//  UI Misc.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 7/7/23.
//

import Foundation
import SwiftUI



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
    
    struct imgNames {
        static let alertCircle      = "ic_alert_circle"
        static let info             = "ic_info"
        static let success          = "ic_succes"
        static let checkCircle      = "ic_check_circle"
        static let warning          = "ic_warning"
    }

    struct appButtonTitle {
        static let ok               = "Okay"
        static let cancel           = "Cancel"
    }

} // lmao had gpt make these


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


extension Color {
    static func backgroundForBetResult(_ result: BetResult) -> Color {
        switch result {
        case .notStarted: return K.veryLightBlue
        case .inAction: return K.lightYellow
        case .loss: return K.lightRed
        case .win: return K.lightGreen
        case .forcedLoss: return K.lightRed
        // add other cases as needed
        }
    }
}


struct formatDate {
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
        let calendar = Calendar.current
        let now = Date()
        let nextSunday = calendar.nextDate(after: now, matching: DateComponents(hour: 0, weekday: 2), matchingPolicy: .nextTime)!
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: nextSunday)
        timeRemaining = String(format: "%d : %02d : %02d : %02d", components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }

}
