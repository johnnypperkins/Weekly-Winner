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
        
    
    func fetchUserGroups(userID: String, completion: @escaping ([Group]?, Error?) -> Void) {
        db.collection("users").document(userID).collection("groups").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion(nil, error)
                return
            }

            var groups: [Group] = []

            for document in documents {
                let id = document.documentID
                let groupNum = document.data()["GroupNum"] as? Int ?? 0 // default value if not found
                let totalWon = document.data()["totalWon"] as? Int ?? 0 // default value if not found
                let totalPotentialWon = document.data()["totalPotentialWon"] as? Int ?? 0 // default value if not found
                let groupName = document.data()["groupName"] as? String ?? "null" // default value if not found
                
                let group = Group(id: id, groupNumber: groupNum, dateCreated: "today", totalWon: totalWon, totalPotentialWon: totalPotentialWon, groupName: groupName)
                groups.append(group)
            }
            
            // sorts them based on groupNum
            groups.sort { $0.groupNumber < $1.groupNumber }

            completion(groups, nil)
        }
    }
    
    func setPotentialToWin(potential potentialToWin: Int, groupNumber: Int, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(AuthError.userNotFound)
            return
        }
        
        let db = Firestore.firestore()
        
        // Query the document where the 'groupNumber' field is equal to the given groupNumber
        db.collection("users").document(userID).collection("groups")
            .whereField("GroupNum", isEqualTo: groupNumber)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    // Handle the error
                    completion(err)
                } else if let document = querySnapshot?.documents.first {
                    // Create the data to upload
                    let data: [String: Any] = [
                        "totalPotentialWon": potentialToWin
                    ]
                    
                    // Set the 'potentialToWin' field in the document
                    document.reference.setData(data, merge: true) { error in
                        if let error = error {
                            // Handle the error
                            completion(error)
                        } else {
                            // Upload successful
                            completion(nil)
                        }
                    }
                }
            }
    }
}
