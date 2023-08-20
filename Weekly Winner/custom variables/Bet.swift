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
    var timestamp: Timestamp
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
    if betType == .betHomeSpread || betType == .betAwaySpread {
        if chosenSpread == originalSpread {
           return 0.5
       } else if chosenSpread == originalSpread - 1 {
           return 0.47
       } else if chosenSpread == originalSpread - 2 {
           return 0.44
       } else if chosenSpread == originalSpread - 3 {
           return 0.38
       } else if chosenSpread == originalSpread - 4 {
           return 0.34
       } else if chosenSpread == originalSpread - 5 {
           return 0.32
       } else if chosenSpread == originalSpread - 6 {
           return 0.305
       } else if chosenSpread == originalSpread - 7 {
           return 0.29
       } else if chosenSpread == originalSpread - 8 {
           return 0.28
       } else if chosenSpread == originalSpread - 9 {
           return 0.25
       } else if chosenSpread == originalSpread - 10 {
           return 0.225
       } else if chosenSpread == originalSpread - 11 {
           return 0.205
       } else if chosenSpread == originalSpread - 12 {
           return 0.19
       }  else if chosenSpread == originalSpread + 1 {
           return 0.56
       } else if chosenSpread == originalSpread + 2 {
           return 0.59
       } else if chosenSpread == originalSpread + 3 {
           return 0.62
       } else if chosenSpread == originalSpread + 4 {
           return 0.68
       } else if chosenSpread == originalSpread + 5 {
           return 0.72 // -259
       } else if chosenSpread == originalSpread + 6 {
           return 0.74
       } else if chosenSpread == originalSpread + 7 {
           return 0.76
       } else if chosenSpread == originalSpread + 8 {
           return 0.78
       } else if chosenSpread == originalSpread + 9 {
           return 0.80
       } else if chosenSpread == originalSpread + 10 {
           return 0.82
       }
    } else if betType == .over { // ACTUALLY SPREAD
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread + 1 {
            return 0.485
        } else if chosenSpread == originalSpread + 2 {
            return 0.452
        } else if chosenSpread == originalSpread + 3 {
            return 0.424
        } else if chosenSpread == originalSpread + 4 {
            return 0.397
        } else if chosenSpread == originalSpread + 5 {
            return 0.361
        } else if chosenSpread == originalSpread + 6 {
            return 0.332
        } else if chosenSpread == originalSpread + 7 {
            return 0.305
        } else if chosenSpread == originalSpread + 8 {
            return 0.282
        } else if chosenSpread == originalSpread + 9 {
            return 0.254
        } else if chosenSpread == originalSpread + 10 {
            return 0.236
        } else if chosenSpread == originalSpread + 11 {
            return 0.218
        } else if chosenSpread == originalSpread + 12 {
            return 0.197
        }  else if chosenSpread == originalSpread - 1 {
            return 0.515
        } else if chosenSpread == originalSpread - 2 {
            return 0.55
        } else if chosenSpread == originalSpread - 3 {
            return 0.58
        } else if chosenSpread == originalSpread - 4 {
            return 0.60
        } else if chosenSpread == originalSpread - 5 {
            return 0.64
        } else if chosenSpread == originalSpread - 6 {
            return 0.67
        } else if chosenSpread == originalSpread - 7 {
            return 0.70
        } else if chosenSpread == originalSpread - 8 {
            return 0.72
        } else if chosenSpread == originalSpread - 9 {
            return 0.75
        } else if chosenSpread == originalSpread - 10 {
            return 0.77
        }
    } else if betType == .under {
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread - 1 {
            return 0.485
        } else if chosenSpread == originalSpread - 2 {
            return 0.452
        } else if chosenSpread == originalSpread - 3 {
            return 0.424
        } else if chosenSpread == originalSpread - 4 {
            return 0.397
        } else if chosenSpread == originalSpread - 5 {
            return 0.361
        } else if chosenSpread == originalSpread - 6 {
            return 0.332
        } else if chosenSpread == originalSpread - 7 {
            return 0.305
        } else if chosenSpread == originalSpread - 8 {
            return 0.282
        } else if chosenSpread == originalSpread - 9 {
            return 0.254
        } else if chosenSpread == originalSpread - 10 {
            return 0.236
        } else if chosenSpread == originalSpread - 11 {
            return 0.218
        } else if chosenSpread == originalSpread - 12 {
            return 0.197
        }  else if chosenSpread == originalSpread + 1 {
            return 0.515
        } else if chosenSpread == originalSpread + 2 {
            return 0.55
        } else if chosenSpread == originalSpread + 3 {
            return 0.58
        } else if chosenSpread == originalSpread + 4 {
            return 0.60
        } else if chosenSpread == originalSpread + 5 {
            return 0.64
        } else if chosenSpread == originalSpread + 6 {
            return 0.67
        } else if chosenSpread == originalSpread + 7 {
            return 0.70
        } else if chosenSpread == originalSpread + 8 {
            return 0.72
        } else if chosenSpread == originalSpread + 9 {
            return 0.75
        } else if chosenSpread == originalSpread + 10 {
            return 0.77
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
    if parlayNum == 1 {
        return 10
    } else if parlayNum == 2 {
        return 4
    } else if parlayNum == 3 {
        return 1
    } else if parlayNum == 4 || parlayNum == 5 {
        return -1
    }
    return 5
}
