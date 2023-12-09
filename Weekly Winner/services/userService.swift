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
    
   
    struct MyDocument: Codable {
        var myArray: [String]?
    }
    
}
