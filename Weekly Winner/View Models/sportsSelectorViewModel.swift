//
//  sportsSelectorView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/9/23.
//

import Foundation
import SwiftUI

enum sportsSelecterViewModel: Int, CaseIterable {
    case upcoming
    case NFL
    case NCAAF
    case NBA
    
    var title: String {
        switch self {
            case .upcoming: return "Upcoming"
            case .NFL: return "NFL"
            case .NCAAF: return "NCAAF"
            case .NBA: return "NBA"
        }
    }
        
    
    var imageName: String {
        switch self {
            case .upcoming: return "clock.arrow.circlepath"
            case .NFL: return "football.fill"
            case .NCAAF: return "figure.american.football"
            case .NBA: return "basketball.fill"
        }
    }
    
}
