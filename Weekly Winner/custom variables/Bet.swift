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
    var whichSport: String
    var timestamp: Timestamp
    var points_bought: Int
//    var opposing_Team: String?
//    var commence_Time: Timestamp
//    var homeTeam_FinalScore: Int
//    var awayTeam_FinalScore: Int
    // when game starts
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
func returnOdds(betType: BetType, ogSpr: Int, chsSpr: Int, whichSport: String) -> Double { // this is so retarded
    if whichSport == "NFL" || whichSport == "NCAAF" { // CHANGE
        return NFL_and_NCAAF_Odds(chosenSpread: chsSpr, originalSpread: ogSpr, betType: betType)
    } else if whichSport == "NBA" {
        return NBAOdds(chosenSpread: chsSpr, originalSpread: ogSpr, betType: betType)
    } else if whichSport == "NCAAB" {
        return NCAABOdds(chosenSpread: chsSpr, originalSpread: ogSpr, betType: betType)
    }
    return 0.5
}

func NCAABOdds(chosenSpread: Int, originalSpread: Int, betType: BetType) -> Double {
    var total_calc = 0.0
    if betType == .over {
         total_calc = 1
    } else {
        total_calc = 0
    }
    if chosenSpread == originalSpread - 0 {
        return abs(total_calc - 0.5)
    } else if chosenSpread == originalSpread + 1 {
        return abs(total_calc - 0.524)
    } else if chosenSpread == originalSpread - 1 {
        return abs(total_calc - 0.476)
    } else if chosenSpread == originalSpread + 2 {
        return abs(total_calc - 0.556)
    } else if chosenSpread == originalSpread - 2 {
        return abs(total_calc - 0.444)
    } else if chosenSpread == originalSpread + 3 {
        return abs(total_calc - 0.574)
    } else if chosenSpread == originalSpread - 3 {
        return abs(total_calc - 0.426)
    } else if chosenSpread == originalSpread + 4 {
        return abs(total_calc - 0.592)
    } else if chosenSpread == originalSpread - 4 {
        return abs(total_calc - 0.408)
    } else if chosenSpread == originalSpread + 5 {
        return abs(total_calc - 0.615)
    } else if chosenSpread == originalSpread - 5 {
        return abs(total_calc - 0.385)
    } else if chosenSpread == originalSpread + 6 {
        return abs(total_calc - 0.643)
    } else if chosenSpread == originalSpread - 6 {
        return abs(total_calc - 0.357)
    } else if chosenSpread == originalSpread + 7 {
        return abs(total_calc - 0.667)
    } else if chosenSpread == originalSpread - 7 {
        return abs(total_calc - 0.333)
    } else if chosenSpread == originalSpread + 8 {
        return abs(total_calc - 0.692)
    } else if chosenSpread == originalSpread - 8 {
        return abs(total_calc - 0.308)
    } else if chosenSpread == originalSpread + 9 {
        return abs(total_calc - 0.714)
    } else if chosenSpread == originalSpread - 9 {
        return abs(total_calc - 0.286)
    } else if chosenSpread == originalSpread + 10 {
        return abs(total_calc - 0.733)
    } else if chosenSpread == originalSpread - 10 {
        return abs(total_calc - 0.267)
    } else if chosenSpread == originalSpread + 11 {
        return abs(total_calc - 0.753)
    } else if chosenSpread == originalSpread - 11 {
        return abs(total_calc - 0.247)
    } else if chosenSpread == originalSpread + 12 {
        return abs(total_calc - 0.773)
    } else if chosenSpread == originalSpread - 12 {
        return abs(total_calc - 0.227)
    } else if chosenSpread == originalSpread + 13 {
        return abs(total_calc - 0.798)
    } else if chosenSpread == originalSpread - 13 {
        return abs(total_calc - 0.202)
    } else if chosenSpread == originalSpread + 14 {
        return abs(total_calc - 0.815)
    } else if chosenSpread == originalSpread - 14 {
        return abs(total_calc - 0.185)
    } else if chosenSpread == originalSpread + 15 {
        return abs(total_calc - 0.831)
    } else if chosenSpread == originalSpread - 15 {
        return abs(total_calc - 0.169)
    }
    return 0.5

}

func NBAOdds(chosenSpread: Int, originalSpread: Int, betType: BetType) -> Double {
    if betType == .betHomeSpread || betType == .betAwaySpread {
        if (chosenSpread == originalSpread - 0) {
            return 0.5;
        } else if (chosenSpread == originalSpread + 1) {
            return 0.524;
        } else if (chosenSpread == originalSpread - 1) {
            return 0.476;
        } else if (chosenSpread == originalSpread + 2) {
            return 0.545;
        } else if (chosenSpread == originalSpread - 2) {
            return 0.455;
        } else if (chosenSpread == originalSpread + 3) {
            return 0.574;
        } else if (chosenSpread == originalSpread - 3) {
            return 0.426;
        } else if (chosenSpread == originalSpread + 4) {
            return 0.600;
        } else if (chosenSpread == originalSpread - 4) {
            return 0.400;
        } else if (chosenSpread == originalSpread + 5) {
            return 0.636;
        } else if (chosenSpread == originalSpread - 5) {
            return 0.364;
        } else if (chosenSpread == originalSpread + 6) {
            return 0.667;
        } else if (chosenSpread == originalSpread - 6) {
            return 0.333;
        } else if (chosenSpread == originalSpread + 7) {
            return 0.692;
        } else if (chosenSpread == originalSpread - 7) {
            return 0.308;
        } else if (chosenSpread == originalSpread + 8) {
            return 0.718;
        } else if (chosenSpread == originalSpread - 8) {
            return 0.282;
        } else if (chosenSpread == originalSpread + 9) {
            return 0.744;
        } else if (chosenSpread == originalSpread - 9) {
            return 0.256;
        } else if (chosenSpread == originalSpread + 10) {
            return 0.767;
        } else if (chosenSpread == originalSpread - 10) {
            return 0.233;
        } else if (chosenSpread == originalSpread + 11) {
            return 0.783;
        } else if (chosenSpread == originalSpread - 11) {
            return 0.217;
        } else if (chosenSpread == originalSpread + 12) {
            return 0.798;
        } else if (chosenSpread == originalSpread - 12) {
            return 0.202;
        } else if (chosenSpread == originalSpread + 13) {
            return 0.815;
        } else if (chosenSpread == originalSpread - 13) {
            return 0.185;
        } else if (chosenSpread == originalSpread + 14) {
            return 0.831;
        } else if (chosenSpread == originalSpread - 14) {
            return 0.169;
        } else if (chosenSpread == originalSpread + 15) {
            return 0.845;
        } else if (chosenSpread == originalSpread - 15) {
            return 0.155;
        }
    } else if betType == .over || betType == .under {
        var total_calc = 0.0
        if betType == .under {
             total_calc = 1
        } else {
            total_calc = 0
        }
        if (chosenSpread == originalSpread - 0) {
            return abs(total_calc - 0.5);
        } else if (chosenSpread == originalSpread - 1) {
            return abs(total_calc - 0.512);
        } else if (chosenSpread == originalSpread + 1) {
            return abs(total_calc - 0.488);
        } else if (chosenSpread == originalSpread - 2) {
            return abs(total_calc - 0.524);
        } else if (chosenSpread == originalSpread + 2) {
            return abs(total_calc - 0.476);
        } else if (chosenSpread == originalSpread - 3) {
            return abs(total_calc - 0.535);
        } else if (chosenSpread == originalSpread + 3) {
            return abs(total_calc - 0.465);
        } else if (chosenSpread == originalSpread - 4) {
            return abs(total_calc - 0.545);
        } else if (chosenSpread == originalSpread + 4) {
            return abs(total_calc - 0.455);
        } else if (chosenSpread == originalSpread - 5) {
            return abs(total_calc - 0.574);
        } else if (chosenSpread == originalSpread + 5) {
            return abs(total_calc - 0.426);
        } else if (chosenSpread == originalSpread - 6) {
            return abs(total_calc - 0.592);
        } else if (chosenSpread == originalSpread + 6) {
            return abs(total_calc - 0.408);
        } else if (chosenSpread == originalSpread - 7) {
            return abs(total_calc - 0.608);
        } else if (chosenSpread == originalSpread + 7) {
            return abs(total_calc - 0.392);
        } else if (chosenSpread == originalSpread - 8) {
            return abs(total_calc - 0.630);
        } else if (chosenSpread == originalSpread + 8) {
            return abs(total_calc - 0.370);
        } else if (chosenSpread == originalSpread - 9) {
            return abs(total_calc - 0.649);
        } else if (chosenSpread == originalSpread + 9) {
            return abs(total_calc - 0.351);
        } else if (chosenSpread == originalSpread - 10) {
            return abs(total_calc - 0.667);
        } else if (chosenSpread == originalSpread + 10) {
            return abs(total_calc - 0.333);
        } else if (chosenSpread == originalSpread - 11) {
            return abs(total_calc - 0.683);
        } else if (chosenSpread == originalSpread + 11) {
            return abs(total_calc - 0.317);
        } else if (chosenSpread == originalSpread - 12) {
            return abs(total_calc - 0.697);
        } else if (chosenSpread == originalSpread + 12) {
            return abs(total_calc - 0.303);
        } else if (chosenSpread == originalSpread - 13) {
            return abs(total_calc - 0.714);
        } else if (chosenSpread == originalSpread + 13) {
            return abs(total_calc - 0.286);
        } else if (chosenSpread == originalSpread - 14) {
            return abs(total_calc - 0.730);
        } else if (chosenSpread == originalSpread + 14) {
            return abs(total_calc - 0.270);
        } else if (chosenSpread == originalSpread - 15) {
            return abs(total_calc - 0.747);
        } else if (chosenSpread == originalSpread + 15) {
            return abs(total_calc - 0.253);
        }
    }
    return 0.5
}

func NFL_and_NCAAF_Odds(chosenSpread: Int, originalSpread: Int, betType: BetType) -> Double {
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
        } else if chosenSpread == originalSpread - 13 {
            return 0.1825
        } else if chosenSpread == originalSpread - 14 {
            return 0.175
        } else if chosenSpread == originalSpread - 15 {
            return 0.1675
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
        } else if chosenSpread == originalSpread + 11 {
            return 0.83
        } else if chosenSpread == originalSpread + 12 {
            return 0.84
        } else if chosenSpread == originalSpread + 13 {
            return 0.85
        } else if chosenSpread == originalSpread + 14 {
            return 0.86
        } else if chosenSpread == originalSpread + 15 {
            return 0.87
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
        } else if chosenSpread == originalSpread + 13 {
            return 0.182
        } else if chosenSpread == originalSpread + 14 {
            return 0.172
        } else if chosenSpread == originalSpread + 15 {
            return 0.165
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
        }  else if chosenSpread == originalSpread - 11 {
            return 0.79
        } else if chosenSpread == originalSpread - 12 {
            return 0.81
        } else if chosenSpread == originalSpread - 13 {
            return 0.82
        } else if chosenSpread == originalSpread - 14 {
            return 0.83
        } else if chosenSpread == originalSpread - 15 {
            return 0.84
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
        } else if chosenSpread == originalSpread - 13 {
            return 0.182
        } else if chosenSpread == originalSpread - 14 {
            return 0.172
        } else if chosenSpread == originalSpread - 15 {
            return 0.165
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
        } else if chosenSpread == originalSpread + 11 {
            return 0.79
        } else if chosenSpread == originalSpread + 12 {
            return 0.80
        } else if chosenSpread == originalSpread + 13 {
            return 0.81
        } else if chosenSpread == originalSpread + 14 {
            return 0.82
        } else if chosenSpread == originalSpread + 15 {
            return 0.83
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
    if percentage < 1 && percentage > 0 {
        toWin = (1-percentage) / percentage * 100
        return "$" + String(Int(round(toWin)))
    } else {
        return "$0"
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
