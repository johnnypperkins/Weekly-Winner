//
//  inActionChallengeViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/21/24.
//

import Foundation
import Firebase

class inActionChallengeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var challenge: ChallengeTicket
    @Published var opponentChallenge: ChallengeTicket?
    
    
    @Published var selectedGames: [Game] = []
    @Published var opponentTotalBetArrays: [[Bet]] = []
    @Published var opponentAvailableBetsArray: [Int] = []
    
    @Published var selfTotalBetArrays: [[Bet]] = []
    @Published var selfAvailableBetsArray: [Int] = []
    @Published var canDeleteBets: Bool = false
    
    @Published var selfProfilePicURL: String = ""
    @Published var opponentProfilePicURL: String = ""
    
    @Published var opponentUsername: String = ""
    
    
    @Published var errorMessage: String = ""
    
    init(challenge: ChallengeTicket) {
        self.challenge = challenge
        fetchBets(challenge: challenge) {
            
        }
        fetchUserProfilePic(uid: challenge.challengerID == StaticUserData.shared.currentUser.id! ? challenge.receiverIDs[0] : challenge.challengerID){
            
        }
        self.opponentUsername = challenge.challengerID == StaticUserData.shared.currentUser.id! ? StaticUserData.shared.currentUser.username : challenge.opponentUsername
    }
    
    func fetchUserProfilePic(uid: String, completion: @escaping () -> Void) {
        //let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error checking if blocked: \(error.localizedDescription)")
                completion()
            } else {
                let profileImageUrl = documentSnapshot?.data()?["profileImageUrl"] as? String
                self.opponentProfilePicURL = profileImageUrl ?? ""
                completion()
            }
        }
    }
    func fetchGameDocument(byID documentID: String, completion: @escaping (Game?) -> Void) {
            let db = Firestore.firestore()
            
        db.collectionGroup("games").whereField("id", isEqualTo: documentID).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting game document: \(error)")
                    return
                }
                
           if let document = querySnapshot?.documents.first {
                        do {
                            var data = document.data()
                                 if let idd = data["id"] as? String,
                                    let commenceTime = data["commenceTime"] as? Timestamp,
                                    let totalOver = data["totalOver"] as? Double,
                                    let totalUnder = data["totalUnder"] as? Double,
                                    let homeTeam = data["homeTeam"] as? String,
                                    let awayTeam = data["awayTeam"] as? String,
                                    let homeSpread = data["homeSpread"] as? Double,
                                    let awaySpread = data["awaySpread"] as? Double,
                                    let homeTeamScore = data["homeTeamScore"] as? Int,
                                    let awayTeamScore = data["awayTeamScore"] as? Int,
                                    let whichSport = data["whichSport"] as? String? ?? "",
                                    let bet_statistics = data["bet_statistics"] as? [Int],
                                    let total_plays = data["total_plays"] as? Int
 {
                                     
                                        let game = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
                                        
                                        completion(game) // Call completion with the game object

                                }
                            } catch let error {
                                print("Error decoding game document: \(error)")
                                completion(nil)
                        }
                    }
            else {
                print("johnny")
                completion(nil)
            }
        }
    }
    
    func fetchBets(challenge: ChallengeTicket, completion: @escaping () -> Void) {
        // totalBetArrats
        // availableBetsArray
//        let documentLoc:String = {
//            if timeFrame == "weekly" {
//                return "week"
//            } else {
//                return "day"
//            }
//        }()
//        
//        let collectionLoc:String = {
//            if timeFrame == "weekly" {
//                return "currentWeekBets"
//            } else {
//                return "currentDayBets"
//            }
//        }()
//        
        let query = self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("bets").collection("currentWeekBets")
            .whereField("groupID", isEqualTo: challenge.customID)
        query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.selfTotalBetArrays.removeAll() // Clear previous data
                for (index, parlayMax) in challenge.ticketFormat.enumerated() {
                    let betTempArr = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                        return try? queryDocumentSnapshot.data(as: Bet.self)
                    }.filter { $0.betNumber == index+1 }.prefix(parlayMax))
                    self.selfTotalBetArrays.append(betTempArr)
                }
 
                self.selfAvailableBetsArray.removeAll()
                for (index, parlayMax) in challenge.ticketFormat.enumerated() {
                    let betArray = self.selfTotalBetArrays[index]
                    if betArray.filter({ $0.groupID == challenge.customID }).count >= parlayMax {
                        //print("Appending betNumber:", parlayIndex + 1) // Debug print
                        self.selfAvailableBetsArray.append(-1)
                    } else {
                        if betArray.contains(where: { $0.result == .loss }) {
                            self.selfAvailableBetsArray.append(-1)
                        } else {
                            self.selfAvailableBetsArray.append(index+1)
                        }
                    }
                }

                if let error = error {
                    print(error)
                } else {
               
                }

                // Call completion handler
                completion()
            }
        }
    }
    
    func fetchOpponentBets(challenge: ChallengeTicket, completion: @escaping () -> Void) {
        // totalBetArrats
        // availableBetsArray
//        let documentLoc:String = {
//            if timeFrame == "weekly" {
//                return "week"
//            } else {
//                return "day"
//            }
//        }()
//
//        let collectionLoc:String = {
//            if timeFrame == "weekly" {
//                return "currentWeekBets"
//            } else {
//                return "currentDayBets"
//            }
//        }()
//
        let query = self.db.collection("users").document(StaticUserData.shared.currentUser.id! == challenge.challengerID ? challenge.receiverIDs[0] : challenge.challengerID).collection("challenges").document("bets").collection("currentWeekBets")
            .whereField("groupID", isEqualTo: challenge.customID)
        query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.opponentTotalBetArrays.removeAll() // Clear previous data
                for (index, parlayMax) in challenge.ticketFormat.enumerated() {
                    let betTempArr = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                        return try? queryDocumentSnapshot.data(as: Bet.self)
                    }.filter { $0.betNumber == index+1 }.prefix(parlayMax))
                    self.opponentTotalBetArrays.append(betTempArr)
                }
 
                self.opponentAvailableBetsArray.removeAll()
                for (index, parlayMax) in challenge.ticketFormat.enumerated() {
                    let betArray = self.opponentTotalBetArrays[index]
                    if betArray.filter({ $0.groupID == challenge.customID }).count >= parlayMax {
                        //print("Appending betNumber:", parlayIndex + 1) // Debug print
                        self.opponentAvailableBetsArray.append(-1)
                    } else {
                        if betArray.contains(where: { $0.result == .loss }) {
                            self.opponentAvailableBetsArray.append(-1)
                        } else {
                            self.opponentAvailableBetsArray.append(index+1)
                        }
                    }
                }

                if let error = error {
                    print(error)
                } else {
               
                }

                // Call completion handler
                completion()
            }
        }
    }
    
    func fetchChallengeTicket(by customID: String, uid: String, completion: @escaping (ChallengeTicket?) -> Void) {
            db.collection("users")
                .document(uid)
                .collection("challenges")
                .document("tickets")
                .collection("currentChallengeTickets")
                .whereField("customID", isEqualTo: customID)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        completion(nil)
                        return
                    }

                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        print("No documents found for customID: \(customID)")
                        completion(nil)
                        return
                    }

                    let document = documents.first! // Assuming there's only one document per customID
                    let data = document.data()

                    // Create ChallengeTicket from the data
                    if let challengeTicket = self.createChallengeTicket(from: data) {
                        DispatchQueue.main.async { [self] in
                            self.opponentChallenge = challengeTicket
                            fetchOpponentBets(challenge: challengeTicket) {
                                
                            }
                            completion(challengeTicket)
                        }
                    } else {
                        completion(nil)
                    }
                }
        }

        private func createChallengeTicket(from data: [String: Any]) -> ChallengeTicket? {
            guard let customID = data["customID"] as? String,
                  let username = data["username"] as? String,
                  let opponentUsername = data["opponentUsername"] as? String,
                  let dateCreated = data["dateCreated"] as? Timestamp,
                  let wagerAmount = data["wagerAmount"] as? Double,
                  let currencyChosen = data["currencyChosen"] as? String,
                  let totalPotentialWon = data["totalPotentialWon"] as? Double,
                  let totalWon = data["totalWon"] as? Double,
                  let status = data["status"] as? String,
                  let challengerID = data["challengerID"] as? String,
                  let receiverIDs = data["receiverIDs"] as? [String],
                  let ticketFormat = data["ticketFormat"] as? [Int],
                  let gameIDs = data["gameIDs"] as? [String],
                  let gamesToPlay = data["gamesToPlay"] as? Int,
                  let gamesPlayed = data["gamesPlayed"] as? Int else {
                      print("Document data is incomplete or of incorrect type.")
                      return nil
                  }

            return ChallengeTicket(
                customID: customID,
                username: username,
                opponentUsername: opponentUsername,
                dateCreated: dateCreated,
                wagerAmount: wagerAmount,
                currencyChosen: currencyChosen,
                totalPotentialWon: totalPotentialWon,
                totalWon: totalWon,
                status: status,
                challengerID: challengerID,
                receiverIDs: receiverIDs,
                ticketFormat: ticketFormat,
                gameIDs: gameIDs,
                gamesToPlay: gamesToPlay,
                gamesPlayed: gamesPlayed
            )
        }
    
}

