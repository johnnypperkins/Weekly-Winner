//
//  statsViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 9/29/23.
//

import Foundation
import FirebaseFirestore

class statsViewModel: ObservableObject {
    @Published var top10players: [topStat] = []
    private var db = Firestore.firestore()
    
    init() {
        setTop10 {
            print("SET TOP 10", self.top10players)
        }
    }

    func setTop10(completion: @escaping () -> Void) {
        db.collection("Misc").document("rankedUsersBS").collection("rankings").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching top 10 players: \(error)")
                completion()
                return
            }
            print("I AM HERE")
            guard let documents = snapshot?.documents else {
                print("No documents found")
                completion()
                return
            }
            
            self.top10players = documents.compactMap { (document) -> topStat? in
                print("AT LEAST TRIED")
                print(try? document.data(as: topStat.self))
                return try? document.data(as: topStat.self)
            }.sorted(by: { $0.betScore > $1.betScore }) // Sort by betScore in descending order
            
            completion()
        }
    }

}
