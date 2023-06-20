//
//  Ticket.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/17/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Ticket: Identifiable {
    @DocumentID var id: String?
    var groupID: String
    var overall: Double = 0
    
    
}
