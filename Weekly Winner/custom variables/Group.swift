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
    var groupName: String
    var dateCreated: Timestamp // will fix later
    var groupImageURL: String
    var groupSlogan: String
    var groupAdmin: String // userID
    var password: String?
    var keywordsForLookup: [String] {
        [self.groupName.generateStringSequence()].flatMap { $0 }
    }
}

struct GroupStats {
    var groupID: String
    var average: Double
    var median: Double
    var max: Int
    var min: Int
    var avgRank: Int
}
