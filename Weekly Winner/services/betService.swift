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
            "gameID": bet.gameID,
            "groupID": bet.groupID,
            "whichSport": bet.whichSport,
            "timestamp": bet.timestamp,
            "points_bought": bet.points_bought
            
        ]
        
        if let teamBetOn = bet.teamBetOn {
            data["teamBetOn"] = teamBetOn
        }
        
        // Upload the data to Firestore
        ref = db.collection("users").document(userID).collection("bets").document("week").collection("currentWeekBets").addDocument(data: data) { error in
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
                let betLine = document.data()["betLine"] as? Int ?? -99 // default value if not found
                
                let popularBet = MostPopularBet(teamName: teamName, betLine: betLine, betType: BetType(rawValue: betType) ?? .None, gameID: gameID)
                popularBets.append(popularBet)
            }
            
            // sorts them based on groupNum
            //groups.sort { $0.groupNumber < $1.groupNumber }

            completion(popularBets, nil)
        }
    }
    
//    func fetchGroupStatistics(groupID: String, completion: @escaping ([GroupStats]?, Error?) -> Void) {
//        guard let userID = Auth.auth().currentUser?.uid else {
//            completion(group, AuthError.userNotFound)
//            return
//        }
//        
//        
//    }
    
}

enum AuthError: Error {
    case userNotFound
}

 

func getTitle(for index: Int, iteration: Int) -> String {
    switch index {
    case 0:
        return "Straight #\(iteration + 1)"
    case 1:
        return "2 Leg #\(iteration + 1)"
    case 2:
        return "3 Leg #\(iteration + 1)"
    case 3:
        return "4 Leg #\(iteration + 1)"
    case 4:
        return "5 Leg #\(iteration + 1)"
    default:
        return "Other #\(iteration + 1)"
    }
}

func getTitle2(ticketFormat: [Int], betNumber: Int) -> String {
    var betTotals = 0
    for (index, parlayType) in ticketFormat.enumerated() {
        for specificParlay in 0..<parlayType {
            betTotals += 1
            if betNumber == betTotals {
                return getTitle(for: index, iteration: specificParlay)
            }
        }
    }
    return "null"
}
