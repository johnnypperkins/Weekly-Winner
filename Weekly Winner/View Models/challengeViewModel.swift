//
//  challengeViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

import Foundation
import Firebase

class challengeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var queriedUsers: [User] = []
    @Published var opponentUsernameExists: Bool = false
    @Published var service = BetService()
    
//    func createGroup(groupImageURL: UIImage?, groupAdminUsername: String, groupName: String, groupSlogan: String, password: String, ticketFormat: [Int]) {
//        
//        if groupImageURL != nil {
//            imageUploader.uploadImage(use: "group", image: groupImageURL!) { URL in
//                
//                self.groupImageURLString = URL
//                self.service.createGroup(groupAdminUsername: groupAdminUsername, groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: ticketFormat, groupUrl: self.groupImageURLString) { result in
//                    switch result {
//                    case .success(let documentID):
//                        print("Document added with ID: \(documentID)")
//                    case .failure(let error):
//                        print("Error adding document: \(error)")
//                    }
//                }
//            }
//        }
//        else {
//            self.service.createGroup(groupAdminUsername: groupAdminUsername, groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: ticketFormat, groupUrl: "") { result in
//                switch result {
//                case .success(let documentID):
//                    print("Document added with ID: \(documentID)")
//                case .failure(let error):
//                    print("Error adding document: \(error)")
//                }
//            }
//        }
//    }
    
    
    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).limit(to: 5).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    func checkUsernameAvailable(username: String, completion: @escaping (User?, Bool) -> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("username", isEqualTo: username.lowercased()).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, false) // Return nil and false in case of error
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                // User exists
                // Manual mapping to create a User object
                if let data = documents.first?.data() {
                    let user = User(
                        id: data["id"] as? String,
                        username: data["username"] as? String ?? "",
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        profileImageUrl: data["profileImageUrl"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        dateJoined: data["dateJoined"] as? Timestamp ?? Timestamp(),
                        instagram: data["instagram"] as? String ?? "",
                        promoCode: data["promoCode"] as? String ?? "",
                        country: data["country"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        birthday: data["birthday"] as? Timestamp ?? Timestamp(),
                        gender: data["gender"] as? String ?? ""
                    )
                    completion(user, true)
                } else {
                    completion(nil, true)
                }
            } else {
                // No user found
                completion(nil, false)
            }
        }
    }


    
}
