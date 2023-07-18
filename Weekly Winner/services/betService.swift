//
//  betService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/19/23.
//

import Foundation
import Firebase

class BetService {
    private let db = Firestore.firestore()
    
    func uploadBet(_ bet: Bet, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(AuthError.userNotFound)
            return
        }
        
        //let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        // Prepare the data to upload
        var data: [String: Any] = [
            "groupNumber": bet.groupNumber,
            "betNumber": bet.betNumber,
            "betType": bet.betType.rawValue,
            "betLine": bet.betLine,
            "betOdds": bet.betOdds,
            "result": bet.result.rawValue,
            "gameID": bet.gameID
        ]
        
        if let teamBetOn = bet.teamBetOn {
            data["teamBetOn"] = teamBetOn
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
    
    func fetchPopularBets(completion: @escaping ([MostPopularBet]?, Error?) -> Void) {
        db.collection("Misc").document("PopularGames").collection("games").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion(nil, error)
                return
            }

            var popularBets: [MostPopularBet] = []

            for document in documents {
                let id = document.documentID
                let teamName = document.data()["teamName"] as? String ?? "null" // default value if not found
                let numTimesPlaced = document.data()["numTimesPlaced"] as? Int ?? 0 // default value if not found
                let gameID = document.data()["gameID"] as? String ?? "xyz"// default value if not found
                let betType = document.data()["betType"] as? String ?? "None"
                //let groupName = document.data()["groupName"] as? String ?? "null" // default value if not found
                
                let popularBet = MostPopularBet(teamName: teamName, betLine: 0, betType: BetType(rawValue: betType) ?? .None, gameID: gameID)
                popularBets.append(popularBet)
            }
            
            // sorts them based on groupNum
            //groups.sort { $0.groupNumber < $1.groupNumber }

            completion(popularBets, nil)
        }
    }
    
}

enum AuthError: Error {
    case userNotFound
}

 

// This function converts the difference between the original spread and the chosenSpread into a percentage. Will then be converted into an actual "moneyline"
func returnOdds(betType: BetType, ogSpr: Int, chsSpr: Int) -> Double {
    let chosenSpread = chsSpr
    let originalSpread = ogSpr
    if betType != .over {
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
    } else if betType == .over {
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
