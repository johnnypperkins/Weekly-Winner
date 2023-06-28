//
//  Bet.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/17/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

struct Bet: Identifiable, Codable {
    @DocumentID var id: String?
    var groupNumber: Int
    var betNumber: Int
    var weekNumber: Int? // I have literally no idea why this was the problem but it was. This needed to be an optional for whatever reason - Reid
    var betStatus: BetStatus
    var betType: BetType
    var teamBetOn: String?
    var betLine: Float
    var betOdds: Float
    var result: BetResult
    var totalType: TotalType?
}

enum BetStatus: String, Codable {
    case open
    case inAction
    case closed
}

enum BetType: String, Codable {
    case spread
    case total
}

enum BetResult: String, Codable {
    case win
    case loss
    case inAction
}

enum TotalType: String, Codable {
    case over
    case under
}

enum BetTeamType: String, Codable {
    case betHomeSpread
    case betAwaySpread
    case over
    case under
    case None
}
