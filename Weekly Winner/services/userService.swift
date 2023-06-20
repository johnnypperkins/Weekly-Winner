//
//  userService.swift
//  Merge
//
//  Created by Johnny Perkins on 2/26/23.
//

import Firebase
import FirebaseFirestoreSwift

struct userService {
    
    func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
            Firestore.firestore().collection("users")
                .document(uid)
                .getDocument { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    
                    guard let user = try? snapshot.data(as: User.self) else { return }
                   completion(user)
                }
        }
    
   
    struct MyDocument: Codable {
        var myArray: [String]?
    }
    
}
