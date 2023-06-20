//
//  betService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/19/23.
//

import Foundation
import Firebase

class BetService {
    
    func uploadBet(_ bet: Bet, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(AuthError.userNotFound)
            return
        }
        
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        // Prepare the data to upload
        var data: [String: Any] = [
            "groupNumber": bet.groupNumber,
            "betNumber": bet.betNumber,
            "betStatus": bet.betStatus.rawValue,
            "betType": bet.betType.rawValue,
            "betLine": bet.betLine,
            "betOdds": bet.betOdds,
            "result": bet.result.rawValue
        ]
        
        if let teamBetOn = bet.teamBetOn {
            data["teamBetOn"] = teamBetOn
        }
        
        if let totalType = bet.totalType {
            data["totalType"] = totalType.rawValue
        }
        
        // Upload the data to Firestore
        ref = db.collection("users").document(userID).collection("bets").addDocument(data: data) { error in
            if let error = error {
                // Handle the error
                completion(error)
            } else {
                // Upload successful
                completion(nil)
            }
        }
    }
}

enum AuthError: Error {
    case userNotFound
}
