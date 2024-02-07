//
//  pendingChallengeViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/19/24.
//

import Foundation
import Firebase

class pendingChallengeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var challenge: ChallengeTicket
    @Published var selectedGames: [Game] = []
    @Published var totalBetArrays: [[Bet]] = []
    @Published var availableBetsArray: [Int] = []
    @Published var canDeleteBets: Bool = true
    
    @Published var ticketFormat: [Int] = []
    @Published var totalWon: Double = 0
    @Published var totalPotentialWon: Double = 0
    @Published var wagerAmount: Double = 0
    @Published var selectedGameIDs = [String]()
    @Published var currencyChosen: String = "PoolBucks"
    @Published var opponentUsername: String = ""
    @Published var opponentID: String = ""
    @Published var opponentProfilePicURL: String = ""
    
    @Published var errorMessage: String = ""
    
    init(challenge: ChallengeTicket) {
        self.challenge = challenge
        fetchSelectedGames(gameIDS: challenge.gameIDs) { games, error in
//            self.selectedGames = games ?? []
            print(self.selectedGames)
            print(challenge.gameIDs)
            print("game ids")
        }
        self.setEmptyTotalBetArray(ticketFormat: challenge.ticketFormat)
        self.setBetAvailability(ticketFormat: challenge.ticketFormat)
        self.calculateTotals(ticketFormat: challenge.ticketFormat)
        self.ticketFormat = challenge.ticketFormat
        self.opponentID = challenge.challengerID
        self.wagerAmount = challenge.wagerAmount
        self.opponentUsername = challenge.opponentUsername
    }

    func setEmptyTotalBetArray(ticketFormat: [Int]) {
        self.totalBetArrays.removeAll() // Clear previous data
        for _ in ticketFormat {
            var tempArr: [Bet] = []
            self.totalBetArrays.append(tempArr)
        }
//        print("TOTAL BET ARRAYS \(self.totalBetArrays)")
    }
    
    
    
    
    func fetchSelectedGames(gameIDS: [String], completion: @escaping ([Game]?, Error?) -> Void) {
        // Reference to the Firestore database
        let db = Firestore.firestore()
        
        // Initialize an array to store fetched games
//        var selectedGames: [Game] = []

        // Loop through each gameID and fetch the corresponding games
        let group = DispatchGroup()
        for gameID in gameIDS {
            group.enter()
            db.collectionGroup("games").whereField("id", isEqualTo: gameID).getDocuments { (querySnapshot, error) in
                defer { group.leave() }
                
                if let error = error {
                    // Handle error and continue to the next gameID
                    print("Error fetching game with ID \(gameID): \(error.localizedDescription)")
                    return
                }

//                for document in querySnapshot!.documents {
//                    if let game = try? document.data(as: Game.self) {
//                        selectedGames.append(game)
//                    } else {
//                        print("Error decoding game data for ID: \(gameID)")
//                    }
//                }
                for document in querySnapshot!.documents {
                    let data = document.data()
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
                       let total_plays = data["total_plays"] as? Int {
                        let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
                        if !self.selectedGames.contains(where: { $0.idd == newGame.idd }) {
                                        self.selectedGames.append(newGame)
                                    }
                    }
                    else {
                        print("Error decoding game data for ID: \(gameID)")
                    }
                }
                
            }
        }

        // After all queries are completed, call the completion handler
        group.notify(queue: .main) {
            completion(nil, nil)
        }
    }
    
    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType) -> Bool {
        for betArray in totalBetArrays {
            for bet in betArray {
                if bet.teamBetOn == team && bet.groupNumber == groupNumber && bet.betType == betType  {
                    return false
                }
            }
        }
        return true
    }
    
    func setBetAvailability(ticketFormat: [Int]) {
        self.availableBetsArray.removeAll()
        for (index, parlayMax) in ticketFormat.enumerated() {
            let betArray = self.totalBetArrays[index]
            if betArray.count >= parlayMax {
                //print("Appending betNumber:", parlayIndex + 1) // Debug print
                self.availableBetsArray.append(-1)
            } else {
                if betArray.contains(where: { $0.result == .loss }) {
                    self.availableBetsArray.append(-1)
                } else {
                    self.availableBetsArray.append(index+1)
                }
            }
        }
        print("AVAILABLE BETS ARR \(self.availableBetsArray)")

    }
    
    func uploadChallengeBet(bet: Bet) {
        // stays local
        self.totalBetArrays[bet.betNumber-1].append(bet)
        self.setBetAvailability(ticketFormat: self.ticketFormat)
        self.calculateTotals(ticketFormat: self.ticketFormat)
        
    }
    
    func deleteChallengeBet(bet: Bet) {
        self.totalBetArrays[bet.betNumber-1].removeLast() // THIS DOES NOT WORK FOR PARLAYS. WILL FIX LATER
        self.setBetAvailability(ticketFormat: self.ticketFormat)
        self.calculateTotals(ticketFormat: self.ticketFormat)
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
    
    func calculateTotals(ticketFormat: [Int]) {
        var totalWonLocal: Double = 0.0
        var totalPotentialWonLocal: Double = 0.0

        // Helper function to avoid code duplication
        func calculateForBetArray(_ betArray: [Bet], count: Int) {
            if betArray.count == count {
                let product = betArray.reduce(1.0, { $0 * $1.betOdds })
                let toWin = percentageToTotalWin(percentage: Double(product))
                let potentialWin = Double(toWin.replacingOccurrences(of: "$", with: "")) ?? 0.0
                
                if betArray.allSatisfy({ $0.result == .win }) {
                    totalWonLocal += potentialWin
                }
                
                if betArray.contains(where: ({ $0.result == .loss })) {
                    totalWonLocal -= 100
                }

                // check if not all elements in the array are a win
                if !betArray.allSatisfy({ $0.result == .win }) &&
                    !betArray.contains(where: { $0.result == .loss }) {
                    totalPotentialWonLocal += potentialWin
                }
            }
        }
        for index in 0..<totalBetArrays.count {
            let betArray = totalBetArrays[index]
            calculateForBetArray(betArray, count: ticketFormat[index])
        }

        self.totalWon = totalWonLocal
        self.totalPotentialWon = totalPotentialWonLocal
        self.challenge.totalPotentialWon = totalPotentialWonLocal
        self.challenge.totalPotentialWon = totalPotentialWonLocal
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
    
    func respondToChallenge(acceptedChallenge: Bool, challenge: ChallengeTicket, completion: @escaping () -> Void) {
        let challengerUserId = challenge.challengerID
            let challengerRef = db.collection("users").document(challengerUserId)

            let responderUserId = challenge.receiverIDs[0] // Assuming only one opponent
            let responderRef = db.collection("users").document(responderUserId)
        if acceptedChallenge {
            // Update the status field of the challenge in the current user's collection
            print("challenge accepted")
            self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).updateData(["status": "inAction", "totalPotentialWon": challenge.totalPotentialWon]) { error in
                if let error = error {
                                print("Error updating challenge status: \(error)")
                            } else {
                                print("Challenge status updated for current user")

                                // Update the status field of the challenge in the receiver's collection
                                self.db.collection("users").document(challenge.challengerID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).updateData(["status": "inAction"]) { error in
                                    if let error = error {
                                        print("Error updating challenge status for challenger: \(error)")
                                    } else {
                                        print("Challenge status updated for challenger")

                                        let betsPath = self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("bets").collection("currentWeekBets")
                                        print("Uploading bets...")

                                        for betArray in self.totalBetArrays {
                                            for bet in betArray {
                                                print("Adding bet: \(bet)")
                                    var betData: [String: Any] = [
                                        "groupNumber": bet.groupNumber,
                                        "betNumber": bet.betNumber,
                                        "betType": bet.betType.rawValue,
                                        "betLine": bet.betLine,
                                        "betOdds": bet.betOdds,
                                        "result": bet.result.rawValue,
                                        "gameID": bet.gameID,
                                        "groupID": challenge.customID,
                                        "whichSport": bet.whichSport,
                                        "timestamp": bet.timestamp,
                                        "teamBetOn": bet.teamBetOn,
                                        "points_bought": bet.points_bought,
                                        "timeFrame": ""
                                        
                                    ]
                                    
                                    betsPath.addDocument(data: betData) { error in
                                        if let error = error {
                                            print("Error adding document: \(error)")
                                        }
                                    }
                                }
                            }
                            if challenge.currencyChosen == "poolCoins" {
                                responderRef.updateData(["poolCoins": StaticUserData.shared.currentUser.poolCoins - challenge.wagerAmount])
                                StaticUserData.shared.currentUser.poolCoins = StaticUserData.shared.currentUser.poolCoins - challenge.wagerAmount
                            }
                            else if challenge.currencyChosen == "poolBucks" {
                                responderRef.updateData(["poolBucks": StaticUserData.shared.currentUser.poolBucks - challenge.wagerAmount])
                                StaticUserData.shared.currentUser.poolBucks = StaticUserData.shared.currentUser.poolBucks - challenge.wagerAmount
                            }
                            else {
                                print("Invalid Currency")
                            }
                        }
                    }
                }
            }
            
            
            completion()
        } else {
            self.db.collection("users").document(challenge.challengerID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                if let error = error {
                    print("Error deleting challenge: \(error)")
                }
            }
            
            self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                if let error = error {
                    print("Error deleting challenge: \(error)")
                } else {
                    
                    completion()
                }
            }
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                    do {
                        // Read phase
                        let challengerDoc = try transaction.getDocument(challengerRef)

                        guard let challengerCurrency = challengerDoc.data()?["poolCoins"] as? Double,

                              challengerCurrency >= challenge.wagerAmount else {
                            let errorMessage = "Insufficient funds"
                            errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            return nil
                        }

                        // Write phase
                        let newChallengerCurrency = challengerCurrency + challenge.wagerAmount

                        transaction.updateData([challenge.currencyChosen: newChallengerCurrency], forDocument: challengerRef)


                        return nil
                    } catch let error as NSError {
                        errorPointer?.pointee = error
                        return nil
                    }
                }, completion: { _, error in
                    if let error = error {
                        print("Currency deduction failed: \(error.localizedDescription)")
                    } else {
                        completion()
                    }
                })
        }
    }
    
}

