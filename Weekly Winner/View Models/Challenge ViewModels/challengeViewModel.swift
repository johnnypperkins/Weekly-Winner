//
//  challengeViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

import Foundation
import Firebase

class challengeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var service = BetService()

    @Published var queriedUsers: [User] = []
    @Published var opponentUsernameExists: Bool = false
    @Published var allGames: [Game] = []
    @Published var timeGames: [Game] = []
    @Published var selectedGames: [Game] = []
    @Published var totalBetArrays: [[Bet]] = []
    @Published var availableBetsArray: [Int] = []
    @Published var canDeleteBets: Bool = true
    
    @Published var currentChallenges: [ChallengeTicket] = []
    @Published var opponentChallenges: [ChallengeTicket] = []
    
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
    
    @Published var poolCoins: Double = StaticUserData.shared.currentUser.poolCoins
    @Published var poolBucks: Double = StaticUserData.shared.currentUser.poolBucks
    



    init() {
        self.fetchAllGames() {
            self.fetchTimeGames(amountTime: 1) {
                
            }
        }
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
    
    func submitSelectedGames() {
            // Handle submission logic here
            print("Selected Games: \(selectedGameIDs)")
        }
    
    func setTicketFormat(ticketFormat: [Int]) {
        self.ticketFormat = ticketFormat
    }
    
    func isGameSelected(gameId: String) -> Bool {
        return selectedGameIDs.contains(gameId)
    }
    
    func setEmptyTotalBetArray(ticketFormat: [Int]) {
        self.totalBetArrays.removeAll() // Clear previous data
        for _ in ticketFormat {
            var tempArr: [Bet] = []
            self.totalBetArrays.append(tempArr)
        }
//        print("TOTAL BET ARRAYS \(self.totalBetArrays)")
    }
    
    
    
    
    func toggleGameSelection(_ game: Game) {
        // Assuming 'gameID' is a property of 'Game'
        let gameID = game.idd

        // Check if 'selectedGames' contains a game with the same 'gameID'
        if let index = selectedGames.firstIndex(where: { $0.idd == gameID }) {
            selectedGames.remove(at: index)
            selectedGameIDs.remove(at: index)

            print("\(game) removed")
        } else {
            selectedGames.append(game)
            selectedGameIDs.append(game.idd)
            print("\(game) added")
        }
        
        self.totalPotentialWon = 0
        self.setEmptyTotalBetArray(ticketFormat: self.ticketFormat)
        self.setBetAvailability(ticketFormat: self.ticketFormat)
        self.calculateTotals(ticketFormat: self.ticketFormat)
        
        
        
        print("ALL GAMES IN ARRAY: \(selectedGames)")
        print("ALL GAMES IDS IN ARRAY: \(selectedGameIDs)")
        
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
    
    func fetchUserCoinsAndBucks(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let poolCoins = data?["poolCoins"] as? Double
                let poolBucks = data?["poolBucks"] as? Double
                StaticUserData.shared.currentUser.poolBucks = poolBucks ?? -99
                StaticUserData.shared.currentUser.poolCoins = poolCoins ?? -99
                self.poolBucks = poolBucks ?? -99
                self.poolCoins = poolCoins ?? -99
                print("PoolBucks: \(StaticUserData.shared.currentUser.poolBucks)")
                completion()
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
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
    
    
    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).limit(to: 5).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    func checkUsernameAvailable(username: String, completion: @escaping (User?, Bool) -> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("username", isEqualTo: username.lowercased()).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, false) // Return nil and false in case of error
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                // User exists
                // Manual mapping to create a User object
                if let data = documents.first?.data() {
                    let user = User(
                        id: data["id"] as? String,
                        username: data["username"] as? String ?? "",
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        profileImageUrl: data["profileImageUrl"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        dateJoined: data["dateJoined"] as? Timestamp ?? Timestamp(),
                        instagram: data["instagram"] as? String ?? "",
                        promoCode: data["promoCode"] as? String ?? "",
                        country: data["country"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        birthday: data["birthday"] as? Timestamp ?? Timestamp(),
                        gender: data["gender"] as? String ?? "",
                        poolCoins: data["poolCoins"] as? Double ?? 0,
                        poolBucks: data["poolBucks"] as? Double ?? 0,
                        paymentVerified: data["paymentVerified"] as? String ?? "false"
                    )
                    completion(user, true)
                } else {
                    completion(nil, true)
                }
            } else {
                // No user found
                completion(nil, false)
            }
        }
    }
    
    func fetchTimeGames(amountTime: Int, completion: @escaping () -> Void) {
        self.timeGames.removeAll()

        let now = Date()
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: amountTime, to: now)!

        self.timeGames = allGames.filter { game in
            let commenceTime = game.commenceTime.dateValue()
            return commenceTime >= now && commenceTime <= endDate
        }

        completion()
    }

    
    func fetchAllGames(completion: @escaping () -> Void) {
        self.allGames.removeAll()
        var tempGames: [Game] = []
        let sportsArr = ["NFL", "NCAAF", "NBA", "NCAAB"]
        let group = DispatchGroup()

        for sport in sportsArr {
            group.enter() // Enter the group for each sport

            Firestore.firestore().collection("Book").document(sport).collection("games")
                .order(by: "commenceTime").getDocuments { querySnapshot, error in

                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        group.leave() // Leave the group in case of an error
                        return
                    }

                    var games: [Game] = []

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
                            games.append(newGame)
                        }
                    }

                    tempGames.append(contentsOf: games)
                    group.leave() // Leave the group when done processing this sport
                }
        }

        group.notify(queue: .main) {
            self.allGames = tempGames.sorted { $0.commenceTime.dateValue() < $1.commenceTime.dateValue() }
            completion() // Call the completion handler once all sports are processed
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
    }
    
    func checkOpponentCurrency(challengeTicket: ChallengeTicket, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        // Assume you have a "users" collection in Firestore where user data is stored.
        // Replace "users" with your actual Firestore collection name.
        let opponentUserId = challengeTicket.receiverIDs[0] // Assuming only one opponent

        db.collection("users").document(opponentUserId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching opponent's data: \(error)")
                completion(false)
            } else if let document = document, document.exists {
                // Parse opponent's data
                if let opponentData = document.data(),
                   let opponentCurrency = opponentData[challengeTicket.currencyChosen] as? Double {
                    // Compare opponent's currency with wagerAmount
                    if opponentCurrency >= challengeTicket.wagerAmount {
                        // Opponent has enough currency to accept the challenge
                        completion(true)
                    } else {
                        // Opponent lacks enough funds
                        completion(false)
                    }
                } else {
                    print("Invalid opponent data format")
                    completion(false)
                }
            } else {
                print("Opponent document does not exist")
                completion(false)
            }
        }
    }
    
    
    func deductCurrencyFromUsers(challengeTicket: ChallengeTicket, completion: @escaping () -> Void, failure: @escaping (String) -> Void) {
        let db = Firestore.firestore()

        let challengerRef = db.collection("users").document(challengeTicket.challengerID)
//        let opponentRef = db.collection("users").document(challengeTicket.receiverIDs[0]) // Assuming only one opponent

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                // Read phase
                let challengerDoc = try transaction.getDocument(challengerRef)
                

                guard let challengerCurrency = challengerDoc.data()?[challengeTicket.currencyChosen] as? Double,
                      
                      challengerCurrency >= challengeTicket.wagerAmount
                      else {
                    let errorMessage = "Insufficient funds"
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    return nil
                }

                // Write phase
                let newChallengerCurrency = challengerCurrency - challengeTicket.wagerAmount
                if challengeTicket.currencyChosen == "poolCoins" {
                    StaticUserData.shared.currentUser.poolCoins = newChallengerCurrency
                }
                else {
                    StaticUserData.shared.currentUser.poolBucks = newChallengerCurrency
                }
//                let newOpponentCurrency = opponentCurrency - challengeTicket.wagerAmount

                transaction.updateData([challengeTicket.currencyChosen: newChallengerCurrency], forDocument: challengerRef)
//                transaction.updateData([challengeTicket.currencyChosen: newOpponentCurrency], forDocument: opponentRef)

                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        }, completion: { _, error in
            if let error = error {
                failure("Currency deduction failed: \(error.localizedDescription)")
            } else {
                completion()
            }
        })
    }






    func sendChallenge(username: String, challengeTicket: ChallengeTicket, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        // 1. Send bets to own user
        print("Checking opponent's currency")
//            checkOpponentCurrency(challengeTicket: challengeTicket) { hasEnoughCurrency in
//                print("Checked opponent's currency: \(hasEnoughCurrency)")
//                if hasEnoughCurrency {
                    print("Deducting currency from users")
                    self.deductCurrencyFromUsers(challengeTicket: challengeTicket) {
                        print("Currency deducted successfully")
                    
                    let betsPath = db.collection("users").document(challengeTicket.challengerID).collection("challenges").document("bets").collection("currentWeekBets")
                    for betArray in self.totalBetArrays {
                        for bet in betArray {
                            
                            var betData: [String: Any] = [
                                "groupNumber": bet.groupNumber,
                                "betNumber": bet.betNumber,
                                "betType": bet.betType.rawValue,
                                "betLine": bet.betLine,
                                "betOdds": bet.betOdds,
                                "result": bet.result.rawValue,
                                "gameID": bet.gameID,
                                "groupID": challengeTicket.customID,
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
                    
                    // 2. Send challenge ticket to own user
                    let challengePath = db.collection("users").document(challengeTicket.challengerID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challengeTicket.customID)
                    let challengePath2 = db.collection("users").document(challengeTicket.receiverIDs[0]).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challengeTicket.customID)
                    print("\(challengeTicket) + helllooooooeeoeo     ")
                    print("\(username) + helllooooooeeoeo     ")
                        
                        // YOUR TICKET
                    let challengerTicketData: [String: Any] = [
                        "customID": challengeTicket.customID,
                        "username": username,
                        "opponentUsername": challengeTicket.opponentUsername,
                        "dateCreated": challengeTicket.dateCreated, // Assuming `dateCreated` is a Date object
                        "wagerAmount": challengeTicket.wagerAmount,
                        "currencyChosen": challengeTicket.currencyChosen,
                        "totalPotentialWon": challengeTicket.totalPotentialWon,
                        "totalWon": challengeTicket.totalWon,
                        "status": challengeTicket.status,
                        "challengerID": challengeTicket.challengerID,
                        "receiverIDs": challengeTicket.receiverIDs,
                        "ticketFormat": challengeTicket.ticketFormat,
                        "gameIDs": challengeTicket.gameIDs,
                        "gamesToPlay": challengeTicket.gamesToPlay,
                        "gamesPlayed": challengeTicket.gamesPlayed
                    ]
                        // OPPONENT TICKET
                        let recieverTicketData: [String: Any] = [
                            "customID": challengeTicket.customID,
                            "username": challengeTicket.opponentUsername, // NEEDS TO BE FLIPPED
                            "opponentUsername": username,
                            "dateCreated": challengeTicket.dateCreated, // Assuming `dateCreated` is a Date object
                            "wagerAmount": challengeTicket.wagerAmount,
                            "currencyChosen": challengeTicket.currencyChosen,
                            "totalPotentialWon": 0,
                            "totalWon": 0,
                            "status": challengeTicket.status,
                            "challengerID": challengeTicket.challengerID,
                            "receiverIDs": challengeTicket.receiverIDs, // FLIPPED
                            "ticketFormat": challengeTicket.ticketFormat,
                            "gameIDs": challengeTicket.gameIDs,
                            "gamesToPlay": challengeTicket.gamesToPlay,
                            "gamesPlayed": challengeTicket.gamesPlayed
                        ]

                    
                    challengePath.setData(challengerTicketData) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            completion()
                        }
                    }
                    
                    challengePath2.setData(recieverTicketData) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            completion()
                        }
                    }
                }
            failure: { errorMessage in
                            // Handle the case where currency deduction failed
                print("Currency deduction failed: \(errorMessage)")
                self.errorMessage = errorMessage
                        }
//            } else {
//                // Notify the user that the opponent lacks enough funds
//                print("Opponent lacks the funds to accept the challenge.")
//                self.errorMessage = "Opponent lacks the funds to accept the challenge."
//                completion()
//            }
//        }
    }
    
    func fetchAllOpponentChallenges(completion: @escaping () -> Void) {
        // create collection group at "currentChallengeTickets"
        // I want all documents there that that EITHER have a value called "challengerID" set to a value OR an array called receiverIDs contains a certain value
    }
    
    func fetchChallenges(completion: @escaping () -> Void) {
        let statuses = ["pendingAcceptance", "inAction", "win", "loss", "push"] // Replace with your actual status values

        let query = self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets")
                    .whereField("status", in: statuses)
                    .order(by: "dateCreated", descending: true)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion()
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents found for query")
                completion()
                return
            }

            print("Found \(documents.count) documents")

            self.currentChallenges.removeAll()
            for document in documents {
                let data = document.data()
                if let customID = data["customID"] as? String,
                   let username = data["username"] as? String,
                   let opponentUsername = data["opponentUsername"] as? String,
                   let dateCreated = data["dateCreated"] as? Timestamp, // Or convert to Date if needed
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
                   let gamesPlayed = data["gamesPlayed"] as? Int
                {
                    
                    let challengeTicket = ChallengeTicket(
                        customID: customID,
                        username: username,
                        opponentUsername: opponentUsername,
                        dateCreated: dateCreated, // Converts Timestamp to Date
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
                    self.currentChallenges.append(challengeTicket)
                } else {
                    print("Document data is incomplete or of incorrect type for document: \(document.documentID)")
                }
            }

            print("Completed processing \(self.currentChallenges.count) challenges")
            completion()
        }
    }
    
    

    func fetchAllOpponentChallenges(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let group = DispatchGroup()
        var opponentChallengesLocal: [ChallengeTicket] = []
        self.opponentChallenges.removeAll()
        
        // Query for documents where challengerID matches
        group.enter()
        db.collectionGroup("currentChallengeTickets")
            .whereField("challengerID", isEqualTo: userID)
            .getDocuments { (querySnapshot, error) in

                if let error = error {
                    print("Error getting documents: \(error)")
                    completion()
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found for query")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let customID = data["customID"] as? String,
                       let username = data["username"] as? String,
                       let opponentUsername = data["opponentUsername"] as? String,
                       let dateCreated = data["dateCreated"] as? Timestamp, // Or convert to Date if needed
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
                       let gamesPlayed = data["gamesPlayed"] as? Int
                    {
                        
                        let challengeTicket = ChallengeTicket(
                            customID: customID,
                            username: username,
                            opponentUsername: opponentUsername,
                            dateCreated: dateCreated, // Converts Timestamp to Date
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
                        opponentChallengesLocal.append(challengeTicket)
                    } else {
                        print("Document data is incomplete or of incorrect type for document: \(document.documentID)")
                    }
                }
                
                //group.leave()
            }
        
        // Query for documents where receiverIDs array contains a certain value
      //  group.enter()
        db.collectionGroup("currentChallengeTickets")
            .whereField("receiverIDs", arrayContains: userID)
            .getDocuments { (querySnapshot, error) in

                if let error = error {
                    print("Error getting documents: \(error)")
                    completion()
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found for query")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let customID = data["customID"] as? String,
                       let username = data["username"] as? String,
                       let opponentUsername = data["opponentUsername"] as? String,
                       let dateCreated = data["dateCreated"] as? Timestamp, // Or convert to Date if needed
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
                       let gamesPlayed = data["gamesPlayed"] as? Int
                    {
                        
                        let challengeTicket = ChallengeTicket(
                            customID: customID,
                            username: username,
                            opponentUsername: opponentUsername,
                            dateCreated: dateCreated, // Converts Timestamp to Date
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
                        opponentChallengesLocal.append(challengeTicket)
                    } else {
                        print("Document data is incomplete or of incorrect type for document: \(document.documentID)")
                    }
                }
                
                group.leave()
            }
        
        // Completion handler
        group.notify(queue: .main) {
            self.opponentChallenges = opponentChallengesLocal
            completion()
        }
    }


    
    func respondToChallenge(acceptedChallenge: Bool, challenge: ChallengeTicket, completion: @escaping () -> Void) {
        let challengerUserId = challenge.challengerID
            let challengerRef = db.collection("users").document(challengerUserId)

            let responderUserId = challenge.receiverIDs[0] // Assuming only one opponent
            let responderRef = db.collection("users").document(responderUserId)
        if acceptedChallenge {
            // Update the status field of the challenge in the current user's collection
            self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).updateData(["status": "inAction"]) { error in
                if let error = error {
                    print("Error updating challenge status: \(error)")
                } else {
                    // Update the status field of the challenge in the receiver's collection
                    self.db.collection("users").document(challenge.challengerID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).updateData(["status": "inAction"]) { error in
                        if let error = error {
                            print("Error updating challenge status: \(error)")
                        } else {
                            completion() // Call completion when both updates are successful
                        }
                    }
                }
            }
//            if challenge.currencyChosen == "poolCoins" {
//                responderRef.updateData(["poolCoins": StaticUserData.shared.currentUser.poolCoins - challenge.wagerAmount])
//            }
//            else if challenge.currencyChosen == "poolBucks" {
//                responderRef.updateData(["poolBucks": StaticUserData.shared.currentUser.poolBucks - challenge.wagerAmount])
//            }
//            else {
//                print("Invalid Currency")
//            }
            
        } else {
            self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                if let error = error {
                    print("Error deleting challenge: \(error)")
                } else {
                    // Deleting the challenge from the receiver's collection
                    self.db.collection("users").document(challenge.receiverIDs[0]).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                        if let error = error {
                            print("Error deleting challenge: \(error)")
                        } else {
                            completion() // Call completion when both deletions are successful
                        }
                    }
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




func generateRandomString(length: Int) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomCharacters = (0..<length).compactMap{ _ in characters.randomElement() }
    return String(randomCharacters)
}


/*


*/
