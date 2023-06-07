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
    
    init() {
        getGames()
    }
    
    private let db = Firestore.firestore()
    
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
                               let commenceTime = data["commenceTime"] as? String,
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
