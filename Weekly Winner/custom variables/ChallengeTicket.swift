//
//  HeadToHeadBet.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/2/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChallengeTicket: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var opponentUsername: String
    var uid: String
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
}



enum challengeStatus: String, Codable {
    case pendingAcceptance
    case declined 
    case inAction
    case push
    case win
    case loss
}
