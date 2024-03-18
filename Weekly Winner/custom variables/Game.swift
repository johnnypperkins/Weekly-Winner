//
//  game.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/5/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Game: Identifiable, Decodable, Hashable {
    @DocumentID var id: String?
    var idd: String?
    var awaySpread: Double
    var awayTeam: String
    var homeSpread: Double
    var homeTeam: String
    var commenceTime: Timestamp
    var status: String
    var totalOver: Double
    var totalUnder: Double
    var homeTeamScore: Int
    var awayTeamScore: Int
    var whichSport: String
    
    var bet_statistics: [Int] // Home, Home Stats, Away, Away Stats, Under, Under Stats, Over, Over Stats
    var total_plays: Int
    
    var awayML: Int
    var homeML: Int
    
    var awaySpreadODDS: Int
    var homeSpreadODDS: Int
    
    var totalOverODDS: Int
    var totalUnderODDS: Int
}

struct P {
    static let maxNumGroupsCanJoin = 5
}
