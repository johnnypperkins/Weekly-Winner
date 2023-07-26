//
//  editProfileViewModel.swift
//  Merge
//
//  Created by Johnny Perkins on 5/11/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

class editProfileViewModel: ObservableObject {
    @Published  var firstname: String
    @Published  var lastname: String
    @Published  var username: String
    @Published  var email: String
    @Published  var profileImgURL: String
    private var user1: User
    
    private let db = Firestore.firestore()
    
    init(user: User) {
        self.user1 = user
        firstname = user.firstName
        lastname = user.lastName
        username = user.username
        email = user.email
        profileImgURL = user.profileImageUrl
    }
    
        
    func uploadProfileImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        print("entered1")
        guard let user = Auth.auth().currentUser else { return }
        print("entered01")
        imageUploader.uploadImage(use: "profile", image: image) { profileImageUrl in
            print("entered2")
            Firestore.firestore().collection("users").document(user.uid).updateData(["profileImageUrl": profileImageUrl]) { error in
                print("entered3")
                if error == nil {
                    completion(profileImageUrl)
                } else {
                    // Handle the error accordingly
                    print("Error updating the profile image URL: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
    }

    
        func updateUserInfo() {
            guard let user = Auth.auth().currentUser else {
                // User is not authenticated
                return
            }
            
            
            
            db.collection("users").document(user.uid).updateData([
                "firstName": firstname,
                "lastName": lastname,
                "username": username,
                "profileImageUrl": profileImgURL,
                "keywordsForLookup": user1.keywordsForLookup
            ]) { error in
                if let error = error {
                    print("Error updating user info: \(error.localizedDescription)")
                } else {
                    print("User info updated successfully")
                }
            }
        }
    

    
}
