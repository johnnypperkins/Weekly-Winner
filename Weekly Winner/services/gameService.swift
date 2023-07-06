//
//  gameService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/5/23.
//

import Firebase

struct gameService {
    
    func getGames(whichSport: String) async -> [Game] { // Yeah right you fucking wrote this
        return await withCheckedContinuation { continuation in
            Firestore.firestore().collection("Book").document(whichSport).collection("games")
                .order(by: "commenceTime", descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                        
                    } else {
                        var games: [Game] = []
                        
                        guard let documents = snapshot?.documents, error == nil else {return}
                        games = documents.compactMap { snapshot1 in
                            try? snapshot1.data(as: Game.self)
                            
                        }
                        continuation.resume(returning: games)
                    }
                }
        }
    }
}

