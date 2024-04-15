//
//  betService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/19/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class BetService {
    private let db = Firestore.firestore()
    
    
    func getGamesCommenceTime(completion: @escaping ([Game]) -> Void) {
        Firestore.firestore().collectionGroup("games")
            .whereField("status", in: ["notStarted", "inAction"])
            .order(by: "commenceTime") // Could also order by status
            .getDocuments { querySnapshot, error in // Changed from addSnapshotListener to getDocuments
                guard let snapshot = querySnapshot else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion([]) // Call the completion handler in case of an error
                    return
                }
                
                var games: [Game] = snapshot.documents.compactMap { doc -> Game? in
                    let data = doc.data()
                    guard let idd = data["id"] as? String,
                          let commenceTime = data["commenceTime"] as? Timestamp,
                          let totalOver = data["totalOver"] as? Double,
                          let totalUnder = data["totalUnder"] as? Double,
                          let homeTeam = data["homeTeam"] as? String,
                          let awayTeam = data["awayTeam"] as? String,
                          let homeSpread = data["homeSpread"] as? Double,
                          let awaySpread = data["awaySpread"] as? Double,
                          let homeTeamScore = data["homeTeamScore"] as? Int,
                          let awayTeamScore = data["awayTeamScore"] as? Int,
                          let whichSport = data["whichSport"] as? String,
                          let bet_statistics = data["bet_statistics"] as? [Int],
                          let total_plays = data["total_plays"] as? Int,
                          let awayML = data["awayML"] as? Int,
                          let homeML = data["homeML"] as? Int,
                          let awaySpreadODDS = data["awaySpreadODDS"] as? Int,
                          let homeSpreadODDS = data["homeSpreadODDS"] as? Int,
                          let totalOverODDS = data["totalOverODDS"] as? Int,
                          let totalUnderODDS = data["totalUnderODDS"] as? Int,
                          let status = data["status"] as? String
                            else {
                              return nil
                          }
                    
                   
                    
                    return Game(id: nil, idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, status: status, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays, awayML: awayML, homeML: homeML, awaySpreadODDS: awaySpreadODDS, homeSpreadODDS: homeSpreadODDS, totalOverODDS: totalOverODDS, totalUnderODDS: totalUnderODDS)
                }
                
                completion(games) // Call the completion handler once the games are populated
            }
    }
//    
//    func getGamesCommenceTime(completion: @escaping ([Game], Error?) -> Void) -> ListenerRegistration {
//        let listener = Firestore.firestore().collectionGroup("games")
//            .order(by: "commenceTime")
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    print("Error fetching documents: \(error.localizedDescription)")
//                    completion([], error) // Call the completion handler in case of an error
//                    return
//                }
//
//                guard let snapshot = querySnapshot else {
//                    print("Error fetching documents: error not provided by Firestore")
//                    completion([], NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown Firestore error"]))
//                    return
//                }
//
//                var games: [Game] = snapshot.documents.compactMap { doc -> Game? in
//                    let data = doc.data()
//                    guard let idd = data["id"] as? String,
//                          let commenceTime = data["commenceTime"] as? Timestamp,
//                          let totalOver = data["totalOver"] as? Double,
//                          let totalUnder = data["totalUnder"] as? Double,
//                          let homeTeam = data["homeTeam"] as? String,
//                          let awayTeam = data["awayTeam"] as? String,
//                          let homeSpread = data["homeSpread"] as? Double,
//                          let awaySpread = data["awaySpread"] as? Double,
//                          let homeTeamScore = data["homeTeamScore"] as? Int,
//                          let awayTeamScore = data["awayTeamScore"] as? Int,
//                          let whichSport = data["whichSport"] as? String,
//                          let bet_statistics = data["bet_statistics"] as? [Int],
//                          let total_plays = data["total_plays"] as? Int,
//                          let awayML = data["awayML"] as? Int,
//                          let homeML = data["homeML"] as? Int,
//                          let awaySpreadODDS = data["awaySpreadODDS"] as? Int,
//                          let homeSpreadODDS = data["homeSpreadODDS"] as? Int,
//                          let totalOverODDS = data["totalOverODDS"] as? Int,
//                          let totalUnderODDS = data["totalUnderODDS"] as? Int,
//                          let status = data["status"] as? String
//                        else {
//                          return nil
//                      }
//
//                    return Game(id: nil, idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, status: status, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays, awayML: awayML, homeML: homeML, awaySpreadODDS: awaySpreadODDS, homeSpreadODDS: homeSpreadODDS, totalOverODDS: totalOverODDS, totalUnderODDS: totalUnderODDS)
//                }
//
//                completion(games, nil) // Call the completion handler with the updated list of games
//            }
//
//        return listener // Return the listener registration for cancellation purposes
//    }
    
//    func getGamesCommenceTime(completion: @escaping ([Game], Error?) -> Void) -> ListenerRegistration {
//        let gamesCollection = Firestore.firestore().collectionGroup("games")
//            .order(by: "commenceTime")
//
//        let listener = gamesCollection.addSnapshotListener { (snapshot, error) in
//            if let error = error {
//                completion([], error)
//                return
//            }
//            
//            var games: [Game] = []
//            snapshot?.documents.forEach { document in
//                do {
//                    let game = try document.data(as: Game.self)
//                    games.append(game)
//                } catch let decodeError {
//                    print("Error decoding game: \(decodeError)")
//                }
//            }
//
//            completion(games, nil)
//        }
//
//        return listener
//    }




    
    func uploadBet(_ bet: Bet, timeFrame: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(AuthError.userNotFound)
            return
        }
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "currentWeekBets"
            } else {
                return "currentDayBets"
            }
        }()
        
        var whichToInc = -1
        if bet.betType.rawValue == "betHomeSpread" || bet.betType.rawValue == "betHomeML" {
            whichToInc = 0
        } else if bet.betType.rawValue == "betAwaySpread" || bet.betType.rawValue == "betAwayML" {
            whichToInc = 2
        } else if bet.betType.rawValue == "over" {
            whichToInc = 4
        } else if bet.betType.rawValue == "under" {
            whichToInc = 6
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
            "points_bought": bet.points_bought,
            "timeFrame": timeFrame
            
        ]
        
        if let teamBetOn = bet.teamBetOn {
            data["teamBetOn"] = teamBetOn
        }
        
        // Upload the data to Firestore
        ref = db.collection("users").document(userID).collection("bets").document(documentLoc).collection(collectionLoc).addDocument(data: data) { error in
            if let error = error {
                // Handle the error
                completion(error)
            } else {
                // Upload successful
                completion(nil)
            }
        }

        // Assuming 'db' is your Firestore instance and 'bet' is an object with 'whichSport' and 'gameID' properties
        let ref2 = db.collection("Book").document(bet.whichSport).collection("games").document(bet.gameID)

        ref2.getDocument { (document, error) in
            if let document = document, document.exists {
                var betStatistics = document.get("bet_statistics") as? [Int] ?? []
                var total_plays = document.get("total_plays") as? Int ?? 0
                if whichToInc >= 0 && whichToInc < betStatistics.count {
                    betStatistics[whichToInc] += 1
                    betStatistics[whichToInc+1] += Int(bet.betLine)
                    total_plays += 1
                    ref2.updateData([
                        "bet_statistics": betStatistics,
                        "total_plays": total_plays
                                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            } else if let err = error {
                print("Error getting document: \(err)")
            }
        }
        
        let ticketsCollectionRef = db.collection("users").document(userID).collection("tickets").document("day").collection("currentDayTickets")
        let ref3 = db.collection("users").document(Auth.auth().currentUser!.uid).collection("tickets").document("day").collection("currentDayTickets")
        ref3.whereField("groupID", isEqualTo: "GlobalDaily").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let docRef = ticketsCollectionRef.document(document.documentID)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            var isEnabled = document.get("isEnabled") as? Bool ?? false
                            if !isEnabled {
                                docRef.updateData([
                                    "isEnabled": true
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            }
                        } else if let err = error {
                            print("Error getting document: \(err)")
                        }
                    }
                }
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
    
    func fetchBets(uid: String, currentWeek: Bool, selectedWeek: String, completion: @escaping ([Bet], Error?) -> Void) {

        let documentLoc = "day"
        let collectionLoc = determineBetCollectionLocation(currentWeek: currentWeek)
        guard let startDate = parseDate(from: selectedWeek, currentWeek: currentWeek) else { return }
        let endDate = calculateEndDate(from: startDate, currentWeek: currentWeek)

        let query = self.db.collection("users").document(uid).collection("bets").document(documentLoc).collection(collectionLoc)
                .whereField("groupNumber", isEqualTo: 0) // dont want to make new query
                .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
                .whereField("timestamp", isLessThanOrEqualTo: endDate)
            query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                let localDailyUserBets = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                    return try? queryDocumentSnapshot.data(as: Bet.self)
                })

                if let error = error {
                    print(error)
                    completion([], error)
                } else {
                    completion(localDailyUserBets, nil)
                }
                
            }
        }
    }
    
    func fetchPastTickets(uid: String, completion: @escaping ([Ticket]) -> Void) {
        var pastTicketsLocal: [Ticket] = []
        Firestore.firestore().collection("users").document(uid).collection("tickets")
            .document("day").collection("pastDayTickets")
            .order(by: "dateCreated", descending: true)  // Sorting by dateCreated in descending order
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion([])
                    return
                }
                let documents = querySnapshot?.documents ?? []
                
                for doc in documents {
                    do {
                        if let ticket = try doc.data(as: Ticket?.self) {
                            if ticket.isEnabled {
                                pastTicketsLocal.append(ticket)
                            }
                        }
                    } catch let error {
                        print("Error decoding bet4: \(error.localizedDescription)")
                    }
                }
                completion(pastTicketsLocal)
            }
    }

    
}

extension BetService {
    private func determineBetCollectionLocation(currentWeek: Bool) -> String {
        currentWeek ? "currentDayBets" : "pastDayBets"
    }
    
    private func determineTicketCollectionLocation(currentWeek: Bool) -> String {
        currentWeek ? "currentDayBets" : "pastDayBets"
    }
    
    private func parseDate(from selectedWeek: String, currentWeek: Bool) -> Date? {
        // Check if the selectedWeek is meant to represent the current week
        if currentWeek {
            // If so, calculate the date 3 days ago from today
            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())
            return threeDaysAgo
        } else {
            // Otherwise, parse the selectedWeek string into a Date object
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.date(from: selectedWeek)
        }
    }

    private func calculateEndDate(from startDate: Date, currentWeek: Bool) -> Date {
        var valueAdd: Int {
            if currentWeek {
                return 7 // arbitrary figure to make sure fits in correct time frame
            } else {
                return 1
            }
        }
        return Calendar.current.date(byAdding: .day, value: valueAdd, to: startDate)!
    }
    
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
