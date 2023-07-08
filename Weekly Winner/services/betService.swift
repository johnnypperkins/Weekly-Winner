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

 

// This function converts the difference between the original spread and the chosenSpread into a percentage. Will then be converted into an actual "moneyline"
func returnOdds(betType: Int, ogSpr: Int, chsSpr: Int) -> Double {
    var chosenSpread = chsSpr
    var originalSpread = ogSpr
    if betType != 3 {
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread - 1 {
            return 0.45
        } else if chosenSpread == originalSpread - 2 {
            return 0.4
        } else if chosenSpread == originalSpread - 3 {
            return 0.35
        } else if chosenSpread == originalSpread - 4 {
            return 0.3
        } else if chosenSpread == originalSpread - 5 {
            return 0.25
        }  else if chosenSpread == originalSpread + 1 {
            return 0.55
        } else if chosenSpread == originalSpread + 2 {
            return 0.6
        } else if chosenSpread == originalSpread + 3 {
            return 0.65
        } else if chosenSpread == originalSpread + 4 {
            return 0.7
        } else if chosenSpread == originalSpread + 5 {
            return 0.75
        }
    } else if betType == 3 {
        if chosenSpread == originalSpread {
            return 0.5
        } else if chosenSpread == originalSpread + 1 {
            return 0.45
        } else if chosenSpread == originalSpread + 2 {
            return 0.4
        } else if chosenSpread == originalSpread + 3 {
            return 0.35
        } else if chosenSpread == originalSpread + 4 {
            return 0.3
        } else if chosenSpread == originalSpread + 5 {
            return 0.25
        }  else if chosenSpread == originalSpread - 1 {
            return 0.55
        } else if chosenSpread == originalSpread - 2 {
            return 0.6
        } else if chosenSpread == originalSpread - 3 {
            return 0.65
        } else if chosenSpread == originalSpread - 4 {
            return 0.7
        } else if chosenSpread == originalSpread - 5 {
            return 0.75
        }
    }
    return 0.5
}

func percentageToML(percentage: Double) -> String { // gets ML from percentage
    var ML: Double
    if percentage <= 0.5 {
        ML = (1-percentage) / percentage * 100
        return "+" + String(format: "%.0f", ML)
    } else if percentage > 0.5 && percentage < 1 {
        ML = percentage / (1-percentage) * -100
        return String(format: "%.0f", ML)
    } else {
        return "n/a"
    }
}

func percentageToTotalWin(percentage: Double) -> String {
    var toWin: Double
    if percentage < 1 {
        toWin = (1-percentage) / percentage * 100
        return "$" + String(Int(toWin))
    } else {
        return "n/a"
    }

}
