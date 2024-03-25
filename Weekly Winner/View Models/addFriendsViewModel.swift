//
//  addFriendsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 3/25/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class addFriendsViewModel: ObservableObject {
    @Published var queriedUsers: [User] = []
    
    private let db = Firestore.firestore()
    
    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
 }
