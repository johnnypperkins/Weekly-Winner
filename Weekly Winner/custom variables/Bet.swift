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
    var betType: BetType
    var teamBetOn: String?
    var betLine: Float
    var betOdds: Float
    var result: BetResult
    var gameID: String
}


enum BetType: String, Codable {
    case betHomeSpread
    case betAwaySpread
    case over
    case under
    case None
}

enum BetResult: String, Codable {
    case win
    case loss
    case inAction
    case notStarted
    case forcedLoss
}

struct MostPopularBet: Identifiable, Codable {
    @DocumentID var id: String?
    var teamName: String
    var betLine: Int
    var betType: BetType
    var gameID: String
}
