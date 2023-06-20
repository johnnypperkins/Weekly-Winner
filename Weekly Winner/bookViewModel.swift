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
    private let service = gameService()
    
    private let betService = BetService()
    private let db = Firestore.firestore()
        
        init() {
            getGames()
        }
        
    func uploadBet(team: String, betLine: Double, betOdds: Double, betType: BetType) {
            // Prepare the data to upload
        let bet = Bet(groupNumber: 1, betNumber: 1, weekNumber: 1, betStatus: .open, betType: betType, teamBetOn: team, betLine: Float(betLine), betOdds: Float(betOdds), result: .inAction)
            
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
    
    func getGames() {
        Firestore.firestore().collection("games")
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
                            if let idd = data["id"] as? String,
                               let commenceTime = data["commenceTime"] as? Timestamp,
                               let totalOU = data["totalOU"] as? Double,
                               let homeTeam = data["homeTeam"] as? String,
                               let awayTeam = data["awayTeam"] as? String,
                               let homeSpread = data["homeSpread"] as? Double,
                                let awaySpread = data["awaySpread"] as? Double,
                               let completed = data["completed"] as? Bool {
                                let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: completed, totalOU: totalOU)
                                print("3")
                                games.append(newGame)
                            }
                            print("2")
                        }
                        print("1")
                    }
                    print("hhsdhfs")
                    print(games)
                    self.NFLgames = games
                }
        }
}
