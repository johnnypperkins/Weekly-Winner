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
