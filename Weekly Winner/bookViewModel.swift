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
    @Published var userGroups: [String] = []
    @Published var isGroupsLoaded = false  // Add this line
    @Published var selectedGameType = "NFL"
    
    //private let gameServe = gameService()
    private let betService = BetService()
    private let groupServe = groupService()
    private let db = Firestore.firestore()
        
    init() {
        getGames(whichSport: "NFL")
        getGames(whichSport: "NCAAF")
        fetchUserGroups()
    }
    
    enum GameType: String, CaseIterable, Hashable {
        case collegeFootball = "College Football"
        case nfl = "NFL"
    }
    
    func uploadBet(groupNumber: Int, betNumber: Int, team: String, betLine: Double, betOdds: Double, betType: BetType) {
            // Prepare the data to upload
        let bet = Bet(groupNumber: groupNumber, betNumber: betNumber, weekNumber: 1, betStatus: .open, betType: betType, teamBetOn: team, betLine: Float(betLine), betOdds: Float(betOdds), result: .inAction)
            
            // Perform the upload asynchronously
            betService.uploadBet(bet) { error in
                if let error = error {
                    // Handle the error
                    print("Error uploading bet: \(error)")
                } else {
                    // Upload successful
                    print("Bet uploaded successfully")
                }
            }
        }
    
    func fetchUserGroups() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserGroups(userID: userId) { groups, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let groups = groups {
                self.userGroups = groups
                self.isGroupsLoaded = true  // Set this to true when data is loaded
            }
            print(groups)
            print(userId)
        }
    }
    
    func getGames(whichSport: String) {
        Firestore.firestore().collection("Book").document(whichSport).collection("games")
                .order(by: "commenceTime")
                .addSnapshotListener {  querySnapshot, error in
                    guard (querySnapshot?.documents) != nil else {
                        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    var games: [Game] = []
                    
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            print("test")
                            if let idd = data["id"] as? String,
                               let commenceTime = data["commenceTime"] as? Timestamp,
                                let totalOver = data["totalOver"] as? Double,
                                let totalUnder = data["totalUnder"] as? Double,
                                let homeTeam = data["homeTeam"] as? String,
                                let awayTeam = data["awayTeam"] as? String,
                               let homeSpread = data["homeSpread"] as? Double,
                               let awaySpread = data["awaySpread"] as? Double {
//                               let completed = data["completed"] as? Bool {
                            let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder)
                                print("3")
                                
                                games.append(newGame)
                            } else {
                                print("There is an error")
                            }
                            print(data["totalOver"])
                            print("2")
                        }
                        print("1")
                    }
                    print("hhsdhfs")
                    print(games)
                    if (whichSport == "NFL") {
                        self.NFLgames = games
                    } else if (whichSport == "NCAAF") {
                        self.NCAAFGames = games
                    }
                    
                }
        }
}
