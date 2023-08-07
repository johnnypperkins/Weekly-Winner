//
//  createGroupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/15/23.
//

import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI
import Firebase

class createGroupsViewModel: ObservableObject {
    @Published var service = groupService()
        
    func createGroup(groupName: String, groupSlogan: String, password: String, ticketFormat: [Int]) {
        service.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: ticketFormat) { result in
                switch result {
                case .success(let documentID):
                    print("Document added with ID: \(documentID)")
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
            }
        }
    
    func checkIfGroupNameTaken(_ groupName: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let groupRef = db.collection("groups")
        let query = groupRef.whereField("groupName", isEqualTo: groupName)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
            } else {
                if let snapshot = snapshot, snapshot.documents.count > 0 {
                    // Group name exists in the collection
                    completion(true)
                } else {
                    // Group name doesn't exist
                    completion(false)
                }
            }
        }
    }
}
