//
//  HeadToHeadBet.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/2/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChallengeTicket {
    var customID: String
    var username: String
    var opponentUsername: String
    var dateCreated: Timestamp // will fix later
    var wagerAmount: Double
    var currencyChosen: String
    var totalPotentialWon: Double
    var totalWon: Double
    var status: String
    var challengerID: String
    var receiverIDs: [String]
    var ticketFormat: [Int]
    var gameIDs: [String]
    var gamesToPlay: Int
    var gamesPlayed: Int
    
}

struct DirectChallengeTicket {
    var customID: String
    
    var senderUsername: String
    var senderID: String
    var senderOdds: Int
    var senderBetType: BetType
    var senderWagerAmount: Double

    
    var receiverUsername: String
    var receiverID: String
    var receiverOdds: Int
    var receiverBetType: BetType
    var receiverWagerAmount: Double
    
    var dateCreated: Timestamp // will fix later
    var currencyChosen: String
    var status: String
    var gameIDs: [String]
    var challengeType: String

}

enum currencyType {
    case poolBucks
    case poolCoins
    case null
}


enum challengeStatus: String, Codable {
    case pendingAcceptance
    case declined 
    case inAction
    case push
    case win
    case loss
}


struct Withdrawal {
    var uid: String
    var dateRequested: Timestamp
    var status: String
    var amount: Double
    var venmoUsername: String
    var customID: String
}
