//
//  Group.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 7/14/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var uid: String
    var groupNumber: Int
    var dateCreated: String = "today" // will fix later
    var totalWon: Int
    var totalPotentialWon: Int
    var groupName: String
}
