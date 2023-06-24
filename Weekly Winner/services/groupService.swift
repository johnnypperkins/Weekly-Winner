//
//  groupService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/23/23.
//

import Foundation
import Firebase

class groupService {
    private let db = Firestore.firestore()
        
        func fetchUserGroups(userID: String, completion: @escaping ([String]?, Error?) -> Void) {
            db.collection("users").document(userID).collection("groups").getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    completion(nil, error)
                    return
                }
                
                var groups: [String] = []
                
                for document in documents {
                    groups.append(document.documentID)
                }
                print(groups)
                print("hihih")
                
                completion(groups, nil)
            }
        }
}
