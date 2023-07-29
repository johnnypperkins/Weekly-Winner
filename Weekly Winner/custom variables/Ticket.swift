//
//  Ticket.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/17/23.
//


import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Ticket: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var uid: String
    var groupID: String
    var groupNumber: Int
    var dateCreated: String = "today" // will fix later
    var totalWon: Int
    var totalPotentialWon: Int
    var groupName: String
    var rank: String
    var isEnabled: Bool
    var groupAdmin: String
}
