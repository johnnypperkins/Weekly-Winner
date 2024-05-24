//
//  bookViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/5/23.
//

import Foundation
import Firebase
import FirebaseAuth

class bookViewModel: ObservableObject {

    @Published var allGames: [Game] = []
    @Published var allPopularGames: [Game] = []
    
    @Published var queriedUsers: [User] = []
    
    @Published var userTickets: [Ticket] = [] //ticket99
    @Published var isTicketsLoaded = false  // Add this line
    @Published var mostPopularBets: [MostPopularBet] = []
    @Published var arePopularBetsLoaded = false
    
    @Published var currentUserDailyBets: [Bet] = []

    @Published var selectedGameType = "All Games"
    

    private let betService = BetService()
    private let db = Firestore.firestore()
        
    init() {
//        setupGamesListener()
    }
    
    enum GameType: String, CaseIterable, Hashable {
        case collegeFootball = "College Football"
        case nfl = "NFL"
        case NBA = "NBA"
//        case NCAAB = "NCAAB"
        case NHL = "NHL"
        case MLB = "MLB"
//        case EPL = "EPL"
    }
    

    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).limit(to: 5).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    func fetchBets(uid: String, currentWeek: Bool, selectedWeek: String, completion: @escaping () -> Void) {
        betService.fetchBets(uid: uid, currentWeek: currentWeek, selectedWeek: selectedWeek) { bets, error in
            if let error = error {
                print(error)
                completion()
            } else {
                self.currentUserDailyBets = bets
                completion()
            }
        }
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
                completion()
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }

    var listener: ListenerRegistration?
    func setupGamesListener() {
        let gamesCollection = Firestore.firestore().collectionGroup("games")
            .whereField("status", in: ["notStarted", "inAction"])
            .order(by: "commenceTime")
            

        listener = gamesCollection.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for game updates: \(error.localizedDescription)")
                return
            }

            var games: [Game] = []
            snapshot?.documents.forEach { document in
                do {
                        let data = document.data()
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
                    else { return  }
                    
                    let game = Game(id: nil, idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, status: status, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays, awayML: awayML, homeML: homeML, awaySpreadODDS: awaySpreadODDS, homeSpreadODDS: homeSpreadODDS, totalOverODDS: totalOverODDS, totalUnderODDS: totalUnderODDS)
                    if !games.contains(where: {$0.homeTeam == game.homeTeam && $0.awayTeam == game.awayTeam}) {
                        games.append(game)
                    } else {
                        print("THERE ARE DUPLICATES \(game.homeTeam), \(game.awayTeam)")
                        games.removeAll { $0.homeTeam == game.homeTeam && $0.awayTeam == game.awayTeam }
                    }
                    
                } catch let decodeError {
                    print("Error decoding game: \(decodeError)")
                }
            }

            // Process the fetched games data right here
            DispatchQueue.main.async {
                self.updateGameData(with: games)
            }
        }
    }

    func updateGameData(with games: [Game]) {
        self.allGames = games
        self.allPopularGames = games.filter { $0.total_plays > 0 }
        self.allPopularGames.sort { $0.total_plays > $1.total_plays }
    }

    func removeListener() {
        listener?.remove()
    }
    
    
    
    func uploadBet(groupNumber: Int, groupID: String, betNumber: Int, team: String, betLine: Double, betOdds: Double, betType: BetType, gameID: String, whichSport: String, points_bought: Int, timeFrame: String, completion: @escaping (Error?) -> Void) {
            // Prepare the data to upload
        let bet = Bet(groupNumber: groupNumber, groupID: groupID, betNumber: betNumber, weekNumber: 1, betType: betType, teamBetOn: team, betLine: Float(betLine), betOdds: Float(betOdds), result: .notStarted, gameID: gameID, whichSport: whichSport, timestamp: Timestamp(date: Date()), points_bought: points_bought)
            
            // Perform the upload asynchronously
            betService.uploadBet(bet, timeFrame: timeFrame) { error in
                if let error = error {
                    // Handle the error
                    print("Error uploading bet: \(error)")
                    completion(error)
                } else {
                    // Upload successful
                    print("Bet uploaded successfully")
                    completion(nil)
                }
            }
        }
    
    
    func fetchMostPopularBets() {
        betService.fetchPopularBets() { popularBets, error in
            if let error = error {
                print("Error fetching popular bets: \(error.localizedDescription)")
            } else {
                self.mostPopularBets = popularBets ?? []
                self.arePopularBetsLoaded = true
            }
        }
    }
    
    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType, betArray: [Bet]) -> Bool {
        
        for bet in betArray {
            if bet.teamBetOn == team && bet.groupNumber == groupNumber {
                return false
            }
        }
        return true
    }
    
}


/// ALL BOOK RELATED STATIC FUNCTIONS
/// 
func returnOppBetType(betType: BetType) -> BetType {
    switch betType {
    case .betHomeSpread:
        return .betAwaySpread
    case .betAwaySpread:
        return .betHomeSpread
    case .over:
        return .under
    case .under:
        return .over
    case .betHomeML:
        return .betAwayML
    case .betAwayML:
        return .betHomeML
    case .None:
        return .over
    }
}

func returnTeamString(game: Game, betType: BetType) -> String {
    if betType == .betHomeML || betType == .betHomeSpread {
        return "\(game.homeTeam)"
    } else if betType == .betAwayML || betType == .betAwaySpread {
        return "\(game.awayTeam)"
    } else {
        return "\(game.homeTeam)" + "/" + "\(game.awayTeam)"
    }
}

func returnMLString(game: Game, betType: BetType) -> String {
    if betType == .betHomeML {
        return game.homeML > 0 ? "+\(game.homeML)" : "\(game.homeML)"
    } else if betType == .betAwayML {
        return game.awayML > 0 ? "+\(game.awayML)" : "\(game.awayML)"
    } else if betType == .betHomeSpread {
        return game.homeSpreadODDS > 0 ? "+\(game.homeSpreadODDS)" : "\(game.homeSpreadODDS)"
    } else if betType == .betAwaySpread {
        return game.awaySpreadODDS > 0 ? "+\(game.awaySpreadODDS)" : "\(game.awaySpreadODDS)"
    } else if betType == .over {
        return game.totalOverODDS > 0 ? "+\(game.totalOverODDS)" : "\(game.totalOverODDS)"
    } else if betType == .under {
        return game.totalUnderODDS > 0 ? "+\(game.totalUnderODDS)" : "\(game.totalUnderODDS)"
    } else {
        return ""
    }
}

func returnSpreadString(game: Game, betType: BetType) -> String {
    switch betType {
    case .betHomeSpread:
        return (game.homeSpread > 0 ? "+" : "") + (isWholeNumber(game.homeSpread) ? String(format: "%.0f", game.homeSpread) : String(game.homeSpread))
    case .betAwaySpread:
        return (game.awaySpread > 0 ? "+" : "") + (isWholeNumber(game.awaySpread) ? String(format: "%.0f", game.awaySpread) : String(game.awaySpread))
    case .over:
        return "o" + (isWholeNumber(game.totalOver) ? String(format: "%.0f", game.totalOver) : String(game.totalOver))
    case .under:
        return "u" + (isWholeNumber(game.totalUnder) ? String(format: "%.0f", game.totalUnder) : String(game.totalUnder))
    case .betHomeML:
        return "ML"
    case .betAwayML:
        return "ML"
    case .None:
        return ""
    }
}


func returnWagerStringFormat(betTypeOfButton: BetType, game: Game) -> String {
    if betTypeOfButton == .betHomeSpread {
        if (game.homeSpread < 0) {
            if isWholeNumber(game.homeSpread) {
                return String(format: "%.0f", game.homeSpread)
            } else {
                return String(format: "%.1f", game.homeSpread)
            }
        } else {
            if isWholeNumber(game.homeSpread) {
                return "+" + String(format: "%.0f", game.homeSpread)
            } else {
                return "+" + String(format: "%.1f", game.homeSpread)
            }
        }
    } else if betTypeOfButton == .betAwaySpread {
        if (game.awaySpread < 0) {
            if isWholeNumber(game.awaySpread) {
                return String(format: "%.0f", game.awaySpread)
            } else {
                return String(format: "%.1f", game.awaySpread)
            }
        } else {
            if isWholeNumber(game.awaySpread) {
                return "+" + String(format: "%.0f", game.awaySpread)
            } else {
                return "+" + String(format: "%.1f", game.awaySpread)
            }
        }
    } else if betTypeOfButton == .over {
        if isWholeNumber(game.totalOver) {
            return "o" + String(format: "%.0f", game.totalOver)
        } else {
            return "o" + String(format: "%.1f", game.totalOver)
        }
    } else if betTypeOfButton == .under {
        if isWholeNumber(game.totalUnder) {
            return "u" + String(format: "%.0f", game.totalUnder)
        } else {
            return "u" + String(format: "%.1f", game.totalUnder)
        }
    } else {
        switch betTypeOfButton {
            case .betHomeSpread:
                return "" // will never reach
            case .betAwaySpread:
                return "" // will never reach
            case .over:
                return "o\(game.totalOver)"
            case .under:
                return "u\(game.totalUnder)"
            case .betHomeML:
                return game.homeML > 100 ? "+\(game.homeML)" : "\(game.homeML)"
            case .betAwayML:
                return game.awayML > 100 ? "+\(game.awayML)" : "\(game.awayML)"
            case .None:
                return ""
        }
    }
}


func returnOpponentWagerAmount(wagerAmount: Double, odds1: Int, odds2: Int, betType: BetType, game: Game) -> Double {
    if odds1 >= -110 && odds1 <= -100 && odds2 >= -110 && odds2 <= -100 { // if -107/-103 or -105, -105, then just keep it simple and make users have same amount to potentially win
        return wagerAmount
    } else { // if something like -170 and +200, then make the potential winnings of the challenging users bets that that the wager that the receiving user must make
        // -116, +105 --> 29 to win 25, 25 to win 26ish
        return returnPotentialWinnings(wagerAmount: wagerAmount, MLOdds: odds1)
    }
}

func returnOddsFromBetType(betType: BetType, game: Game) -> Int {
    switch betType {
    case .betHomeSpread:
        return game.homeSpreadODDS
    case .betAwaySpread:
        return game.awaySpreadODDS
    case .over:
        return game.totalOverODDS
    case .under:
        return game.totalUnderODDS
    case .betHomeML:
        return game.homeML
    case .betAwayML:
        return game.awayML
    case .None:
        return -99
    }
}

func returnSpreadFromBetType(betType: BetType, game: Game) -> Double {
    switch betType {
    case .betHomeSpread:
        return game.homeSpread
    case .betAwaySpread:
        return game.awaySpread
    case .over:
        return game.totalOver
    case .under:
        return game.totalUnder
    case .betHomeML:
        return 0
    case .betAwayML:
        return 0
    case .None:
        return -99
    }
}

func returnPotentialWinnings(wagerAmount: Double, MLOdds: Int) -> Double {
    if MLOdds > 0 {
        return wagerAmount*Double(MLOdds)/100
    } else {
        return wagerAmount*(100/((-1)*Double(MLOdds)))
    }
}
