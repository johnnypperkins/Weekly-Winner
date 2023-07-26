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
        
    func createGroup(groupName: String, groupSlogan: String, password: String) {
            service.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password) { result in
                switch result {
                case .success(let documentID):
                    print("Document added with ID: \(documentID)")
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
            }
        }
}
