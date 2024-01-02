//
//  HeadToHeadBet.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/2/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct HeadToHeadBet: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var uid: String
    var groupID: String
    var groupNumber: Int
    var dateCreated: Timestamp // will fix later
    var totalWon: Int
    var totalPotentialWon: Int
    var groupName: String
    var rank: String
    var isEnabled: Bool
    var groupAdmin: String
    var ticketFormat: [Int]
}
