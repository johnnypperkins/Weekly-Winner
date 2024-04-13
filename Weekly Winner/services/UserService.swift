//
//  userService.swift
//  Merge
//
//  Created by Johnny Perkins on 2/26/23.
//

import Firebase
import FirebaseFirestoreSwift

struct UserService {
    
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
 
    func unfollow(uid: String, friendId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("friends").document(friendId).delete() { error in
            if let error = error {
                print("Error removing friend: \(error)")
            } else {
                print("Friend successfully removed.")
            }
        }
    }

    func follow(uid: String, friendId: String, username: String, url: String) {
        let db = Firestore.firestore()
        
        // Now includes the username in the document
        db.collection("users").document(uid).collection("friends").document(friendId).setData(["username": username, "profileImageURL": url]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                print("Friend successfully added.")
            }
        }
    }

   
    struct MyDocument: Codable {
        var myArray: [String]?
    }
    
}
