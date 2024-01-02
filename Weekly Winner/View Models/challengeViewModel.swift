//
//  challengeViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

import Foundation
import Firebase

class challengeViewModel: ObservableObject {
    private let db = Firestore.firestore()

    @Published var opponentUsernameExists: Bool = false
    
    func checkUsernameAvailable(username: String, completion: @escaping () -> Void) {
        let usersCollection = db.collection("users")
                usersCollection.whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion() // Handle error appropriately
            } else {
                if let snapshot = querySnapshot, snapshot.documents.isEmpty {
                    self.opponentUsernameExists = false
                    completion()
                } else {
                    self.opponentUsernameExists = true
                    completion()
                }
            }
        }
    }
    
}
