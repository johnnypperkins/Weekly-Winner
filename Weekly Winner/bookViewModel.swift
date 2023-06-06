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
    @Published var NFLgames: [game] = []
    private let service = gameService()
    
    init() {
        getGames()
    }
    
    private let db = Firestore.firestore()
    
    func getGames() {
        Firestore.firestore().collection("games")
                .order(by: "commenceTime")
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    let games = documents.compactMap { queryDocumentSnapshot -> game? in
                        return try? queryDocumentSnapshot.data(as: game.self)
                    }
                    print("hhsdhfs")
                    self?.NFLgames = games
                }
        }
}
