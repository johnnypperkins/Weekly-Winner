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
            print(documents)
            
            var groupsDict: [Int: String] = [:]
            
            for document in documents {
                if let groupNum = document.data()["GroupNum"] as? Int {
                    groupsDict[groupNum] = document.documentID
                }
            }
            
            let sortedGroups = Array(groupsDict.sorted(by: { $0.key < $1.key }).map { $0.value }) // sorts them based on groupnum
            
            completion(sortedGroups, nil)
        }
    }
}

//class groupService {
//    private let db = Firestore.firestore()
//
//        func fetchUserGroups(userID: String, completion: @escaping ([String]?, Error?) -> Void) {
//            db.collection("users").document(userID).collection("groups").getDocuments { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    completion(nil, error)
//                    return
//                }
//
//                var groups: [String] = []
//
//                for document in documents {
//                    groups.append(document.documentID)
//                }
//                print(groups)
//                print("hihih")
//
//                completion(groups, nil)
//            }
//        }
//}
