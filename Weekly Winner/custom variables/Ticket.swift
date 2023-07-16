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
    var groupName: String
    var dateCreated: Timestamp // will fix later
    var groupImageURL: String
    var groupSlogan: String
    var groupAdmin: String
    var password: String?
}
