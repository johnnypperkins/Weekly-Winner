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
    
    @Published var ticketFormat: [Int] = []
    @Published var totalWon: Double = 0
    @Published var totalPotentialWon: Double = 0
    @Published var wagerAmount: Double = 0
    @Published var selectedGameIDs = [String]()
    @Published var currencyChosen: String = "PoolBucks"
    @Published var opponentUsername: String = ""
    @Published var opponentID: String = ""
    



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
        
        print("ALL GAMES IN ARRAY: \(selectedGames)")
        
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
                        gender: data["gender"] as? String ?? ""
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
    

    func sendChallenge(challengeTicket: ChallengeTicket, completion: @escaping () -> Void) {
        let db = Firestore.firestore()

        // 1. Send bets to own user
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

        let challengeTicketData: [String: Any] = [
            "customID": challengeTicket.customID,
            "username": challengeTicket.username,
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
            "gameIDs": challengeTicket.gameIDs
        ]

        challengePath.setData(challengeTicketData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                completion()
            }
        }
        
        challengePath2.setData(challengeTicketData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func fetchChallenges(completion: @escaping () -> Void) {
        let statuses = ["pendingAcceptance", "inAction"] // Replace with your actual status values

        let query = self.db.collection("users").document(StaticUserData.shared.currentUser.id ?? "").collection("challenges").document("tickets").collection("currentChallengeTickets")
                    .whereField("status", in: statuses)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion()
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents")
                completion()
                return
            }
            
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
                   let gameIDs = data["gameIDs"] as? [String] {
                    
                    let challengeTicket = ChallengeTicket(
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
                        gameIDs: gameIDs
                    )
                    self.currentChallenges.append(challengeTicket)
                } else {
                    print("Document data is incomplete or of incorrect type for document: \(document.documentID)")
                }
            }
            print("CHALLENGES: \(self.currentChallenges)")
            completion()
        }
    }
    
    func respondToChallenge(acceptedChallenge: Bool, challenge: ChallengeTicket, completion: @escaping () -> Void) {
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
