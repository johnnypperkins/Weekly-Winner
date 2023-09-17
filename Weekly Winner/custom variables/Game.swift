//
//  game.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/5/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Game: Identifiable, Decodable {
    @DocumentID var id: String?
    var idd: String
    var awaySpread: Double
    var awayTeam: String
    var homeSpread: Double
    var homeTeam: String
    var commenceTime: Timestamp
    var completed: Bool
    var totalOver: Double
    var totalUnder: Double
    var homeTeamScore: Int
    var awayTeamScore: Int
}

struct P {
    static let maxNumGroupsCanJoin = 5
}
