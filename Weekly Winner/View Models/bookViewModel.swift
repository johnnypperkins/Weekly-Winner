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
    @Published var allGames: [Game] = []
    
    @Published var NFLgamesPopular: [Game] = []
    @Published var NCAAFGamesPopular: [Game] = []
    @Published var NBAGamesPopular: [Game] = []
    @Published var NCAABGamesPopular: [Game] = []
    @Published var allGamesPopular: [Game] = []

    
    
    
    @Published var userTickets: [Ticket] = [] //ticket99
    @Published var isTicketsLoaded = false  // Add this line
    @Published var mostPopularBets: [MostPopularBet] = []
    @Published var arePopularBetsLoaded = false

    @Published var selectedGameType = "All Games"
    

    private let betService = BetService()
    private let groupServe = groupService()
    private let db = Firestore.firestore()
        
    init() {
        getGamesCommenceTime(whichSport: "NFL"){
            self.combineGamesCommence()
        }
        getGamesCommenceTime(whichSport: "NBA"){
            self.combineGamesCommence()
        }
        getGamesCommenceTime(whichSport: "NCAAF") {
            self.combineGamesCommence()
        }
        getGamesCommenceTime(whichSport: "NCAAB") {
            self.combineGamesCommence()
        }
        
        getGamesMostPopular(whichSport: "NFL"){
            self.combineGamesPopular()
        }
        getGamesMostPopular(whichSport: "NBA"){
            self.combineGamesPopular()
        }
        getGamesMostPopular(whichSport: "NCAAF") {
            self.combineGamesPopular()
        }
        getGamesMostPopular(whichSport: "NCAAB") {
            self.combineGamesPopular()
        }
        fetchUserTickets()
    }
    
    enum GameType: String, CaseIterable, Hashable {
        case collegeFootball = "College Football"
        case nfl = "NFL"
        case NBA = "NBA"
    }
    
    func combineGamesCommence() {
        // Combine all games
        var combinedGames = NFLgames + NCAAFGames + NBAGames + NCAABGames
        
        // Sort the combined array based on commencement time
        combinedGames.sort { game1, game2 in
            return game1.commenceTime.dateValue() < game2.commenceTime.dateValue()
        }
        
         allGames = combinedGames
        
    }
    
    func combineGamesPopular() {
        // Combine all games
        var combinedGamesPopular = NFLgamesPopular + NCAAFGamesPopular + NBAGamesPopular + NCAABGamesPopular
        
        // Sort the combined array based on commencement time
        combinedGamesPopular.sort { game1, game2 in
            return game1.commenceTime.dateValue() < game2.commenceTime.dateValue()
        }
         allGamesPopular = combinedGamesPopular
    }
    
    
    
    func uploadBet(groupNumber: Int, groupID: String, betNumber: Int, team: String, betLine: Double, betOdds: Double, betType: BetType, gameID: String, whichSport: String, points_bought: Int, completion: @escaping (Error?) -> Void) {
            // Prepare the data to upload
        let bet = Bet(groupNumber: groupNumber, groupID: groupID, betNumber: betNumber, weekNumber: 1, betType: betType, teamBetOn: team, betLine: Float(betLine), betOdds: Float(betOdds), result: .notStarted, gameID: gameID, whichSport: whichSport, timestamp: Timestamp(date: Date()), points_bought: points_bought)
            
            // Perform the upload asynchronously
            betService.uploadBet(bet) { error in
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
    
    
    
    func fetchUserTickets() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserTickets(userID: userId) { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                self.userTickets = tickets
                self.isTicketsLoaded = true  // Set this to true when data is loaded
            }
            //print(groups)
            //print(userId)
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
    
    func getGamesCommenceTime(whichSport: String, completion: @escaping () -> Void) {
        Firestore.firestore().collection("Book").document(whichSport).collection("games")
            .order(by: "commenceTime")
            .addSnapshotListener {  querySnapshot, error in
                guard (querySnapshot?.documents) != nil else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion() // Call the completion handler in case of an error
                    return
                }
                
                var games: [Game] = []
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
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
                            let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
                            games.append(newGame)
                        }
                    }
                }

                if (whichSport == "NFL") {
                    self.NFLgames = games
                } else if (whichSport == "NCAAF") {
                    self.NCAAFGames = games
                } else if (whichSport == "NBA") {
                    self.NBAGames = games
                } else if (whichSport == "NCAAB") {
                    self.NCAABGames = games
                }
                
                completion() // Call the completion handler once the games are populated
            }
    }
    
    func getGamesMostPopular(whichSport: String, completion: @escaping () -> Void) {
        Firestore.firestore().collection("Book").document(whichSport).collection("games")
            .order(by: "total_plays")
            .addSnapshotListener {  querySnapshot, error in
                guard (querySnapshot?.documents) != nil else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion() // Call the completion handler in case of an error
                    return
                }
                
                var games: [Game] = []
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
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
                            let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
                            if total_plays > 0 {
                                games.append(newGame)
                            }
                        }
                    }
                }

                if (whichSport == "NFL") {
                    self.NFLgamesPopular = games
                } else if (whichSport == "NCAAF") {
                    self.NCAAFGamesPopular = games
                } else if (whichSport == "NBA") {
                    self.NBAGamesPopular = games
                } else if (whichSport == "NCAAB") {
                    self.NCAABGamesPopular = games
                }
                
                completion() // Call the completion handler once the games are populated
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
    
    
}
