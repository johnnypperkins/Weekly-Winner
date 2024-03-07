//
//  userService.swift
//  Merge
//
//  Created by Johnny Perkins on 2/26/23.
//

import Firebase
import FirebaseFirestoreSwift

struct userService {
    
    func fetchUser(uid: String, completion: @escaping (User?, Bool) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            guard let snapshot = snapshot else {
                completion(nil, false) // Return false if there's an issue with document retrieval
                return
            }
            
            if let user = try? snapshot.data(as: User.self) {
                completion(user, true) // Return true and the user object if successfully retrieved
            } else {
                completion(nil, false) // Return false if there's an issue converting data to User
            }
        }
    }
    
    
    func isFollowed (id: String) async -> Bool {
        var iss = true
        let db = Firestore.firestore()
        
        // Get a reference to the document to be read
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        try await docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                guard let array = data?["friends"] as? [String]
                else {docRef.setData(["friends": []], merge: true) { error in
                    if let error = error {
                        print("Error creating array field: \(error)")
                    } else {
                        print("Array field created successfully.")
                    }
                    
                }
                    return
                }
                
                
                // Check if the string is in the array field
                if array.contains(id) {
                    print("The string is in the array.")
                    iss = true
                } else {
                    print("The string is not in the array.")
                    iss = false
                }
            }
        }
        
        return iss
    }
    func unfollow(uid: String, id: String){
        Firestore.firestore().collection("users")
            .document(uid)
            .updateData(["friends": FieldValue.arrayRemove([id])
                        ])
        Firestore.firestore().collection("users")
            .document(id)
            .updateData(["friends": FieldValue.arrayRemove([uid])
                        ])
    }
    func Follow(uid: String, id: String){
        Firestore.firestore().collection("users")
            .document(uid)
            .updateData(["friends": FieldValue.arrayRemove([id])
                        ])
        Firestore.firestore().collection("users")
            .document(id)
            .updateData(["friends": FieldValue.arrayRemove([uid])
                        ])
    }
   
    struct MyDocument: Codable {
        var myArray: [String]?
    }
    
}
