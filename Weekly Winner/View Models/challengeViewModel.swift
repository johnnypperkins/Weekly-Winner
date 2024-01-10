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
    
    
//    func submitTimeGames() {
//            // Handle submission logic here
//        timeGameIDs = timeGames.map { $0.idd }
//            print("Selected Games: \(timeGameIDs)")
//        }
    
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

}
