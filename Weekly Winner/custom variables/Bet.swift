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
    var groupID: String
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


// This function converts the difference between the original spread and the chosenSpread into a percentage. Will then be converted into an actual "moneyline"
func returnOdds(betType: BetType, ogSpr: Int, chsSpr: Int) -> Double { // this is so retarded
    let chosenSpread = chsSpr
    let originalSpread = ogSpr
    if betType != .over {
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread - 1 {
            return 0.45
        } else if chosenSpread == originalSpread - 2 {
            return 0.4
        } else if chosenSpread == originalSpread - 3 {
            return 0.35
        } else if chosenSpread == originalSpread - 4 {
            return 0.3
        } else if chosenSpread == originalSpread - 5 {
            return 0.25
        } else if chosenSpread == originalSpread - 6 {
            return 0.225
        } else if chosenSpread == originalSpread - 7 {
            return 0.2
        } else if chosenSpread == originalSpread - 8 {
            return 0.175
        } else if chosenSpread == originalSpread - 9 {
            return 0.15
        } else if chosenSpread == originalSpread - 10 {
            return 0.125
        }  else if chosenSpread == originalSpread + 1 {
            return 0.55
        } else if chosenSpread == originalSpread + 2 {
            return 0.6
        } else if chosenSpread == originalSpread + 3 {
            return 0.65
        } else if chosenSpread == originalSpread + 4 {
            return 0.7
        } else if chosenSpread == originalSpread + 5 {
            return 0.75
        } else if chosenSpread == originalSpread + 6 {
            return 0.775
        } else if chosenSpread == originalSpread + 7 {
            return 0.8
        } else if chosenSpread == originalSpread + 8 {
            return 0.825
        } else if chosenSpread == originalSpread + 9 {
            return 0.85
        } else if chosenSpread == originalSpread + 10 {
            return 0.875
        }
    } else if betType == .over {
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread + 1 {
            return 0.45
        } else if chosenSpread == originalSpread + 2 {
            return 0.4
        } else if chosenSpread == originalSpread + 3 {
            return 0.35
        } else if chosenSpread == originalSpread + 4 {
            return 0.3
        } else if chosenSpread == originalSpread + 5 {
            return 0.25
        } else if chosenSpread == originalSpread + 6 {
            return 0.225
        } else if chosenSpread == originalSpread + 7 {
            return 0.2
        } else if chosenSpread == originalSpread + 8 {
            return 0.175
        } else if chosenSpread == originalSpread + 9 {
            return 0.15
        } else if chosenSpread == originalSpread + 10 {
            return 0.125
        }  else if chosenSpread == originalSpread - 1 {
            return 0.55
        } else if chosenSpread == originalSpread - 2 {
            return 0.6
        } else if chosenSpread == originalSpread - 3 {
            return 0.65
        } else if chosenSpread == originalSpread - 4 {
            return 0.7
        } else if chosenSpread == originalSpread - 5 {
            return 0.75
        } else if chosenSpread == originalSpread - 6 {
            return 0.775
        } else if chosenSpread == originalSpread - 7 {
            return 0.8
        } else if chosenSpread == originalSpread - 8 {
            return 0.825
        } else if chosenSpread == originalSpread - 9 {
            return 0.85
        } else if chosenSpread == originalSpread - 10 {
            return 0.875
        }
    }
    return 0.5
}

func percentageToML(percentage: Double) -> String { // gets ML from percentage
    var ML: Double
    if percentage <= 0.5 {
        ML = (1-percentage) / percentage * 100
        return "+" + String(format: "%.0f", ML)
    } else if percentage > 0.5 && percentage < 1 {
        ML = percentage / (1-percentage) * -100
        return String(format: "%.0f", ML)
    } else {
        return "n/a"
    }
}

func percentageToTotalWin(percentage: Double) -> String {
    var toWin: Double
    if percentage < 1 {
        toWin = (1-percentage) / percentage * 100
        return "$" + String(Int(toWin))
    } else {
        return "n/a"
    }

}

func parlayNumToSpread(parlayNum: Int) -> Double {
    if parlayNum == 1 || parlayNum == 2 || parlayNum == 3 || parlayNum == 4 {
        return 10
    } else if parlayNum == 5 || parlayNum == 6 {
        return 4
    } else if parlayNum == 7 {
        return 3
    } else if parlayNum == 8 {
        return 2
    }
    return 5
}
