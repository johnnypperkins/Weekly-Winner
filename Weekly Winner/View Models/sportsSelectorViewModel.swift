//
//  sportsSelectorView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/9/23.
//

import Foundation
import SwiftUI

enum sportsSelecterViewModel: Int, CaseIterable {
    case all_games
    case NFL
    case NCAAF
    case NBA
    case NCAAB
    case NHL
    
    var title: String {
        switch self {
            case .all_games: return "All Games"
            case .NFL: return "NFL"
            case .NCAAF: return "NCAAF"
            case .NBA: return "NBA"
            case .NCAAB: return "NCAAB"
            case .NHL: return "NHL"
        }
    }
        
    
    var imageName: String {
        switch self {
            case .all_games: return "clock.arrow.circlepath"
            case .NFL: return "football.fill"
            case .NCAAF: return "figure.american.football"
            case .NBA: return "basketball.fill"
            case .NCAAB: return "basketball.fill"
            case .NHL: return "figure.hockey"
        }
    }
    
}
