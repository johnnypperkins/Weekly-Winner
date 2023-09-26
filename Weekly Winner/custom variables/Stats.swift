//
//  Stats.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 9/26/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Stats: Decodable {
    var avgOddsPlaced: Double
    var betScore: Double
    var totalBetsPlaced: Int
    var totalBetsWon: Int
}
