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
    @Published var NFLgames: [Game] = []
    @Published var NCAAFGames: [Game] = []
    @Published var NBAGames: [Game] = []
    @Published var NCAABGames: [Game] = []
    @Published var NHLGames: [Game] = []
    @Published var allGames: [Game] = []
    
    @Published var NFLgamesPopular: [Game] = []
    @Published var NCAAFGamesPopular: [Game] = []
    @Published var NBAGamesPopular: [Game] = []
    @Published var NCAABGamesPopular: [Game] = []
    @Published var NHLGamesPopular: [Game] = []
    @Published var allGamesPopular: [Game] = []

    @Published var queriedUsers: [User] = []
    
    
    @Published var userTickets: [Ticket] = [] //ticket99
    @Published var isTicketsLoaded = false  // Add this line
    @Published var mostPopularBets: [MostPopularBet] = []
    @Published var arePopularBetsLoaded = false

    @Published var selectedGameType = "All Games"
    

    private let betService = BetService()
//    private let groupServe = groupService()
    private let db = Firestore.firestore()
        
    init() {
        getGamesCommenceTime() {}
    }
    
    enum GameType: String, CaseIterable, Hashable {
        case collegeFootball = "College Football"
        case nfl = "NFL"
        case NBA = "NBA"
        case NCAAB = "NCAAB"
        case NHL = "NHL"
    }
    
//    func combineGamesCommence() {
//        // Combine all games
//        var combinedGames = NFLgames + NCAAFGames + NBAGames + NCAABGames + NHLGames
//
//        // Sort the combined array based on commencement time
//        combinedGames.sort { game1, game2 in
//            return game1.commenceTime.dateValue() < game2.commenceTime.dateValue()
//        }
//        
//         allGames = combinedGames
//        
//    }
    
    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).limit(to: 5).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    
    func getGamesCommenceTime(completion: @escaping () -> Void) {
        self.allGames.removeAll()
        betService.getGamesCommenceTime() { [weak self] games in
            guard let self = self else { return }
            let now = Date() // Get the current date and time
            for game in games {
                self.allGames.append(game) // Append game to allGames array
            }
            completion()
        }
    }

    
//    func combineGamesPopular() {
//        // Combine all games
//        var combinedGamesPopular = NFLgamesPopular + NCAAFGamesPopular + NBAGamesPopular + NCAABGamesPopular + NHLGamesPopular
//        
//        // Sort the combined array based on commencement time
//        combinedGamesPopular.sort { game1, game2 in
//            return game1.total_plays > game2.total_plays
//        }
//         allGamesPopular = combinedGamesPopular
//    }
    
    
    
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

    
//    func getGamesMostPopular(whichSport: String, completion: @escaping () -> Void) {
//        Firestore.firestore().collection("Book").document(whichSport).collection("games")
//            .order(by: "total_plays", descending: true)
//            .addSnapshotListener {  querySnapshot, error in
//                guard (querySnapshot?.documents) != nil else {
//                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
//                    completion() // Call the completion handler in case of an error
//                    return
//                }
//                
//                var games: [Game] = []
//                
//                if let snapshotDocuments = querySnapshot?.documents {
//                    for doc in snapshotDocuments {
//                        let data = doc.data()
//                        if let idd = data["id"] as? String,
//                           let commenceTime = data["commenceTime"] as? Timestamp,
//                           let totalOver = data["totalOver"] as? Double,
//                           let totalUnder = data["totalUnder"] as? Double,
//                           let homeTeam = data["homeTeam"] as? String,
//                           let awayTeam = data["awayTeam"] as? String,
//                           let homeSpread = data["homeSpread"] as? Double,
//                           let awaySpread = data["awaySpread"] as? Double,
//                           let homeTeamScore = data["homeTeamScore"] as? Int,
//                           let awayTeamScore = data["awayTeamScore"] as? Int,
//                           let whichSport = data["whichSport"] as? String? ?? "",
//                           let bet_statistics = data["bet_statistics"] as? [Int],
//                           let total_plays = data["total_plays"] as? Int
//                        {
//                            let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
//                            if total_plays > 0 {
//                                games.append(newGame)
//                            }
//                        }
//                    }
//                }
//
//                if (whichSport == "NFL") {
//                    self.NFLgamesPopular = games
//                } else if (whichSport == "NCAAF") {
//                    self.NCAAFGamesPopular = games
//                } else if (whichSport == "NBA") {
//                    self.NBAGamesPopular = games
//                } else if (whichSport == "NCAAB") {
//                    self.NCAABGamesPopular = games
//                } else if (whichSport == "NHL") {
//                    self.NHLGamesPopular = games
//                }
//                
//                completion() // Call the completion handler once the games are populated
//            }
//    }

    

    
    
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
