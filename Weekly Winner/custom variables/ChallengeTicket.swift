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
    var uid: String
    var dateCreated: Timestamp // will fix later
    var wagerAmount: Int
    var currencyChosen: String
    var totalPotentialWon: Int
    var totalWon: Int
    var status: String
    var challengerID: String
    var receiverIDs: [String]
    var ticketFormat: [Int]
    var gameIDs: [String]
}



