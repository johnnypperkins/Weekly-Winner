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
    
    @Published var currentChallenges: [DirectChallengeTicket] = []
    @Published var opponentChallenges: [DirectChallengeTicket] = []
    @Published var gamesInChallenges: [Game] = []
    @Published var gamesIDsInChallenges: [String] = []
    @Published var publicPendingChallenges: [DirectChallengeTicket] = []
    
    @Published var fetchedGame: Game?

    
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
    
 
    func fetchChallengeGames(matchingID id: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        var game: Game? = nil
        
        db.collectionGroup("games").whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            
            
            if let error = error {
                print("Error fetching game with ID \(id): \(error)")
                completion()
                return
            }
            
            // Attempt to parse each document into a Game object
            if let documents = snapshot?.documents {
                for document in documents {
                    do {
                        let gameDoc = try document.data(as: Game.self)
                        game = gameDoc
                        self.fetchedGame = game
                        completion()
                    } catch {
                        print("Error decoding game with ID \(document.documentID): \(error)")
                    }

                }
            }
        }
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
            selectedGameIDs.append(game.idd!)
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
        service.getGamesCommenceTime() { games in
            self.allGames = games
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
                               let whichSport = data["whichSport"] as? String,
                               let bet_statistics = data["bet_statistics"] as? [Int],
                               let total_plays = data["total_plays"] as? Int,
                               // Extract additional fields here
                               let awayML = data["awayML"] as? Int,
                               let homeML = data["homeML"] as? Int,
                               let awaySpreadODDS = data["awaySpreadODDS"] as? Int,
                               let homeSpreadODDS = data["homeSpreadODDS"] as? Int,
                               let totalOverODDS = data["totalOverODDS"] as? Int,
                               let totalUnderODDS = data["totalUnderODDS"] as? Int,
                               let status = data["status"] as? String
                            {
                                // Ensure completed is correctly extracted or defaulted

                                // Create the newGame instance with all fields
                                let newGame = Game(id: nil, idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, status: status, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays, awayML: awayML, homeML: homeML, awaySpreadODDS: awaySpreadODDS, homeSpreadODDS: homeSpreadODDS, totalOverODDS: totalOverODDS, totalUnderODDS: totalUnderODDS)
                                completion(newGame)
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

    func reclaimFundFromExpiredChallenge(senderID: String, receiverID: String, customID: String, reclaimAmount: Double, sentToPublic: Bool, completion: @escaping () -> Void ) {
        let db = Firestore.firestore()
        
        let userChallengeRef = db.collection("users").document(senderID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(customID)
        
        let batch = db.batch()
        
        batch.deleteDocument(userChallengeRef)
                
        if !sentToPublic {
            let opponentChallengeRef = db.collection("users").document(receiverID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(customID)
            batch.deleteDocument(opponentChallengeRef)
            
        }
        
        let betsCollectionRef = db.collection("users").document(senderID)
            .collection("challenges").document("bets")
            .collection("currentWeekBets")
        
        // Query the collection for documents where a specific field matches challenge.customID
        betsCollectionRef.whereField("groupID", isEqualTo: customID).getDocuments { (querySnapshot, err) in
            if let err = err { print("Error getting documents: \(err)") } else {
                for document in querySnapshot!.documents {
                    print("Document ID: \(document.documentID) will be deleted.")
                    
                    betsCollectionRef.document(document.documentID).delete() { error in
                        if let error = error {
                            print("Error deleting document: \(error)")
                        } else {
                            print("Document successfully deleted")
                        }
                    }
                }
            }
        }
        
        // Commit the batch
        batch.commit { err in
            if let err = err {
                // Handle any errors that occur during the batch commit
                print("Error deleting challenge documents: \(err)")
                completion()
            } else {
                print("Challenge documents successfully deleted")
                
                // After successfully deleting the challenge documents, increment the user's poolBucks
                let userRef = db.collection("users").document(senderID)
                userRef.updateData([
                    "poolBucks": FieldValue.increment(reclaimAmount)
                ]) { err in
                    if let err = err {
                        // Handle any errors that occur during the update
                        print("Error incrementing poolBucks: \(err)")
                        completion()
                    } else {
                        print("poolBucks successfully incremented by \(reclaimAmount)")
                        completion()
                    }
                }
            }
        }
    }



    
    func fetchChallenges(completion: @escaping () -> Void) {
        let statuses = ["pendingPublicAcceptance", "pendingAcceptance", "inAction", "win", "loss", "push"] // Replace with your actual status values

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
            self.gamesIDsInChallenges.removeAll()
            for document in documents {
                let data = document.data()
                if let customID = data["customID"] as? String,
                   
                    
                   let senderUsername = data["senderUsername"] as? String,
                   let senderID = data["senderID"] as? String,
                   let senderOdds = data["senderOdds"] as? Int,
                   let senderBetTypeRaw = data["senderBetType"] as? String, // Assuming BetType can be initialized from a String
                   
                   let senderWagerAmount = data["senderWagerAmount"] as? Double,
                   
           
                    
                   let receiverUsername = data["receiverUsername"] as? String,
                   let receiverID = data["receiverID"] as? String,
                   let receiverOdds = data["receiverOdds"] as? Int,
                   
             
//                   

//                    
                   let receiverBetTypeRaw = data["receiverBetType"] as? String, // Assuming BetType can be initialized from a String
                   let receiverWagerAmount = data["receiverWagerAmount"] as? Double,
                   
                    
                   let dateCreated = data["dateCreated"] as? Timestamp, // You will adjust this conversion later
                   let currencyChosen = data["currencyChosen"] as? String,
                   let status = data["status"] as? String,
                   let gameIDs = data["gameIDs"] as? [String],
                   let challengeType = data["challengeType"] as? String
                {
                    let senderBetType = BetType(rawValue: senderBetTypeRaw) // Adjust this based on how BetType is defined
                    let receiverBetType = BetType(rawValue: receiverBetTypeRaw) // Adjust this
                    
                    let senderTeamName = data["senderTeamName"] as? String ?? ""
                    let senderBetLine = data["senderBetLine"] as? Double ?? -99
                    let receiverBetLine = data["receiverBetLine"] as? Double ?? -99
                    let receiverTeamName = data["receiverTeamName"] as? String ?? ""
//                    let gameCommenceTime = data["gameCommenceTime"] as? Timestamp ?? Timestamp(date: Date())
                    let gameCommenceTime = data["gameCommenceTime"] as? Timestamp ?? Timestamp(date: Calendar.current.date(from: DateComponents(year: 2002, month: 6, day: 7))!)



                    if let senderBetType = senderBetType, let receiverBetType = receiverBetType {
                        let directChallengeTicket = DirectChallengeTicket(
                            customID: customID,
                            
                            senderUsername: senderUsername,
                            senderID: senderID,
                            senderOdds: senderOdds,
                            senderBetType: senderBetType,
                            
                            senderBetLine: senderBetLine,
                            senderTeamName: senderTeamName,
                            
                            senderWagerAmount: senderWagerAmount,
                            
                            receiverUsername: receiverUsername,
                            receiverID: receiverID,
                            receiverOdds: receiverOdds,
                            receiverBetType: receiverBetType,
                            
                            receiverBetLine: receiverBetLine,
                            receiverTeamName: receiverTeamName,
                            
                            receiverWagerAmount: receiverWagerAmount,
                            dateCreated: dateCreated, // Adjust as necessary for your timestamp conversion
                            currencyChosen: currencyChosen,
                            status: status,
                            gameIDs: gameIDs,
                            gameCommenceTime: gameCommenceTime,
                            challengeType: challengeType
                        )
                        self.currentChallenges.append(directChallengeTicket)
                        self.gamesIDsInChallenges.append(gameIDs[0])
                    } else {
                        print("FETCH CHALLENGES: Error initializing BetType for document: \(document.documentID)")
                    }
                } else {
                    print("FETCH CHALLENGES Document data is incomplete or of incorrect type for document: \(document.documentID)")
                }
            }


            print("Completed processing \(self.currentChallenges.count) challenges")
            completion()
        }
    }
    
    func fetchPublicChallenges(completion: @escaping () -> Void) {
        let statuses = ["pendingPublicAcceptance"] // Replace with your actual status values

        let query = db.collectionGroup("currentChallengeTickets")
            .whereField("status", isEqualTo: "pendingPublicAcceptance")
            .order(by: "dateCreated", descending: true).getDocuments { querySnapshot, error in
                    
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

            self.publicPendingChallenges.removeAll()
            for document in documents {
                let data = document.data()
                if let customID = data["customID"] as? String,
                   
                    
                   let senderUsername = data["senderUsername"] as? String,
                   let senderID = data["senderID"] as? String,
                   let senderOdds = data["senderOdds"] as? Int,
                   let senderBetTypeRaw = data["senderBetType"] as? String, // Assuming BetType can be initialized from a String
                   
                   let senderWagerAmount = data["senderWagerAmount"] as? Double,
                   
           
                    
                   let receiverUsername = data["receiverUsername"] as? String,
                   let receiverID = data["receiverID"] as? String,
                   let receiverOdds = data["receiverOdds"] as? Int,

                   let receiverBetTypeRaw = data["receiverBetType"] as? String, // Assuming BetType can be initialized from a String
                   let receiverWagerAmount = data["receiverWagerAmount"] as? Double,
                   
                    
                   let dateCreated = data["dateCreated"] as? Timestamp, // You will adjust this conversion later
                   let currencyChosen = data["currencyChosen"] as? String,
                   let status = data["status"] as? String,
                   let gameIDs = data["gameIDs"] as? [String],
                   let challengeType = data["challengeType"] as? String
                {
                    let senderBetType = BetType(rawValue: senderBetTypeRaw) // Adjust this based on how BetType is defined
                    let receiverBetType = BetType(rawValue: receiverBetTypeRaw) // Adjust this
                    
                    let senderTeamName = data["senderTeamName"] as? String ?? ""
                    let senderBetLine = data["senderBetLine"] as? Double ?? -99
                    let receiverBetLine = data["receiverBetLine"] as? Double ?? -99
                    let receiverTeamName = data["receiverTeamName"] as? String ?? ""
                    let gameCommenceTime = data["gameCommenceTime"] as? Timestamp ?? Timestamp(date: Calendar.current.date(from: DateComponents(year: 2002, month: 6, day: 7))!)


                    if let senderBetType = senderBetType, let receiverBetType = receiverBetType {
                        let directChallengeTicket = DirectChallengeTicket(
                            customID: customID,
                            
                            senderUsername: senderUsername,
                            senderID: senderID,
                            senderOdds: senderOdds,
                            senderBetType: senderBetType,
                            
                            senderBetLine: senderBetLine,
                            senderTeamName: senderTeamName,
                            
                            senderWagerAmount: senderWagerAmount,
                            
                            receiverUsername: receiverUsername,
                            receiverID: receiverID,
                            receiverOdds: receiverOdds,
                            receiverBetType: receiverBetType,
                            
                            receiverBetLine: receiverBetLine,
                            receiverTeamName: receiverTeamName,
                            
                            receiverWagerAmount: receiverWagerAmount,
                            dateCreated: dateCreated, // Adjust as necessary for your timestamp conversion
                            currencyChosen: currencyChosen,
                            status: status,
                            gameIDs: gameIDs,
                            gameCommenceTime: gameCommenceTime,
                            challengeType: challengeType
                        )
                        self.publicPendingChallenges.append(directChallengeTicket)
                    } else {
                        print("FETCH CHALLENGES: Error initializing BetType for document: \(document.documentID)")
                    }
                } else {
                    print("FETCH CHALLENGES Document data is incomplete or of incorrect type for document: \(document.documentID)")
                }
            }

            print("Completed processing \(self.publicPendingChallenges.count) challenges")
            completion()
        }
    }

    
    func respondToChallenge(acceptedChallenge: Bool, challengeOG: DirectChallengeTicket, publicChallenge: Bool, receiverBet: [String: Any], completion: @escaping () -> Void) {
        var challenge: DirectChallengeTicket = challengeOG
//        if publicChallenge {
//            challenge.receiverID = StaticUserData.shared.currentUser.id!
//            challenge.receiverUsername = StaticUserData.shared.currentUser.username
//        }
        print("here1")
        let senderUserID = challenge.senderID
        let senderRef = db.collection("users").document(senderUserID)
        print("here2")
        var receiverUserID = StaticUserData.shared.currentUser.id!
//        if publicChallenge {
//            receiverUserID =
//        } else {
//            receiverUserID = challenge.receiverID // Assuming only one opponent
//        }
        let receiverRef = db.collection("users").document(receiverUserID)
        print("here3")
        
        if acceptedChallenge {
            // Update the status field of the challenge in the current user's collection
            print("challenge accepted")
            self.db.collection("users").document(senderUserID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).updateData(["status": "inAction", "receiverID": StaticUserData.shared.currentUser.id!, "receiverUsername":StaticUserData.shared.currentUser.username]) { error in
                if let error = error {
                    print("Error updating challenge status: \(error)")
                } else {
                    
                    self.db.collection("users").document(receiverUserID)
                        .collection("challenges").document("tickets")
                        .collection("currentChallengeTickets").document(challenge.customID)
                        .setData([
                            "customID": challenge.customID,
                            "senderUsername": challenge.senderUsername,
                            "senderID": challenge.senderID,
                            "senderOdds": challenge.senderOdds,
                            "senderBetType": challenge.senderBetType.rawValue, // Assuming BetType is an enum
                            "senderBetLine": challenge.senderBetLine,
                            "senderTeamName": challenge.senderTeamName,
                            "senderWagerAmount": challenge.senderWagerAmount,
                            "receiverUsername": StaticUserData.shared.currentUser.username,
                            "receiverID": StaticUserData.shared.currentUser.id!,
                            "receiverOdds": challenge.receiverOdds,
                            "receiverBetType": challenge.receiverBetType.rawValue, // Assuming BetType is an enum
                            "receiverBetLine": challenge.receiverBetLine,
                            "receiverTeamName": challenge.receiverTeamName,
                            "receiverWagerAmount": challenge.receiverWagerAmount,
                            "dateCreated": challenge.dateCreated,
                            "currencyChosen": challenge.currencyChosen,
                            "status": "inAction",
                            "gameIDs": challenge.gameIDs,
                            "challengeType": challenge.challengeType
                        ], merge: true) { error in
                            
                            
                        if let error = error {
                            print("Error updating challenge status for challenger: \(error)")
                        } else {
                            print("Challenge status updated for challenger")

                            let betsPath = self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("bets").collection("currentWeekBets")
                            print("Uploading bets...")
                            betsPath.addDocument(data: receiverBet) { error in
                                if let error = error {
                                    print("Error adding document: \(error)")
                                }
                            }
                            if challenge.currencyChosen == "poolCoins" {
                                receiverRef.updateData(["poolCoins": StaticUserData.shared.currentUser.poolCoins - challenge.receiverWagerAmount])
                                StaticUserData.shared.currentUser.poolCoins = StaticUserData.shared.currentUser.poolCoins - challenge.receiverWagerAmount
                            } else if challenge.currencyChosen == "poolBucks" {
                                receiverRef.updateData(["poolBucks": StaticUserData.shared.currentUser.poolBucks - challenge.receiverWagerAmount])
                                StaticUserData.shared.currentUser.poolBucks = StaticUserData.shared.currentUser.poolBucks - challenge.receiverWagerAmount
                            } else {
                                print("Invalid Currency")
                            }
                            
                            fetchUserFCMToken(uid: challenge.senderID) { token in
                                staticSendNotification(token: token ?? "", message: "\(StaticUserData.shared.currentUser.username) has accepted your challenge!") {
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
            completion()
            
            
            
        } else { // if denied
            self.db.collection("users").document(challenge.senderID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                if let error = error {
                    print("Error deleting challenge: \(error)")
                }
            }
            
            self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets").document(challenge.customID).delete { error in
                if let error = error {
                    print("Error deleting challenge: \(error)")
                }
            }
            
            let betsCollectionRef = db.collection("users").document(challenge.senderID)
                .collection("challenges").document("bets")
                .collection("currentWeekBets")

            // Query the collection for documents where a specific field matches challenge.customID
            betsCollectionRef.whereField("groupID", isEqualTo: challenge.customID).getDocuments { (querySnapshot, err) in
                if let err = err { print("Error getting documents: \(err)") } else {
                    for document in querySnapshot!.documents {
                        print("Document ID: \(document.documentID) will be deleted.")
                        
                        betsCollectionRef.document(document.documentID).delete() { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Document successfully deleted")
                            }
                        }
                    }
                }
            }
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    // Read phase
                    let challengerDoc = try transaction.getDocument(senderRef)

                    if let challengerCurrency = challengerDoc.data()?["poolBucks"] as? Double {
                        let newChallengerCurrency = challengerCurrency + challenge.senderWagerAmount
                        transaction.updateData([challenge.currencyChosen: newChallengerCurrency], forDocument: senderRef)

                    }

                    return nil
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
            }, completion: { _, error in
                if let error = error {
                    print("Currency deduction failed: \(error.localizedDescription)")
                } else {
                    fetchUserFCMToken(uid: challenge.senderID) { token in
                        staticSendNotification(token: token ?? "", message: "\(StaticUserData.shared.currentUser.username) has declined your challenge!") {
                            completion()
                        }
                    }
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
