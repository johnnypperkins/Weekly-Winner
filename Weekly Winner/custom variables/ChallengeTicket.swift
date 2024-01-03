//
//  HeadToHeadBet.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/2/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChallengeBet: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var uid: String
    var groupID: String
    var dateCreated: Timestamp // will fix later
    var totalWon: Int
    var totalPotentialWon: Int
    var groupName: String
    var rank: String
    var isEnabled: Bool
    var groupAdmin: String
    var ticketFormat: [Int]
}
