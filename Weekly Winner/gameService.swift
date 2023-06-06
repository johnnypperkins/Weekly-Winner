//
//  gameService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/5/23.
//

import Firebase

struct gameService {
    
    func getGames() async -> [game] {
        return await withCheckedContinuation { continuation in
            Firestore.firestore().collection("games")
                .order(by: "commenceTime", descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                        
                    } else {
                        var games: [game] = []
                        
                        guard let documents = snapshot?.documents, error == nil else {return}
                        games = documents.compactMap { snapshot1 in
                            try? snapshot1.data(as: game.self)
                            
                        }
                        continuation.resume(returning: games)
                    }
                }
        }
    }
}

