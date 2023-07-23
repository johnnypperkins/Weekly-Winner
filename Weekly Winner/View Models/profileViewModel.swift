//
//  profileViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/23/23.
//


import SwiftUI
import Foundation
import Firebase

class profileViewModel: ObservableObject {
    private let uService = userService()
    @Published var isBlocked: Bool = false
    @Published var isBlockedBy: Bool = false
    @Published var user: User
    
    
    init(user: User) {
        //self.getCountOfStringsInArrayField(user1: user)
        self.user = user
        //self.isFollow = uService.isFollowed(id: user.id!)
        Task{
            await self.checkIfBlocked()
            await self.checkIfBlockedBy()
        }
        //self.fetchLikedTweets()
    }
    
    
    func checkIfBlocked() async {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let blockedUserID = user.id else {
            return
        }
        
        let db = Firestore.firestore()
        
        let blockedByRef = db.collection("users").document(currentUserUID).collection("blockedUsers")
        let blockedByUserDoc = blockedByRef.document(blockedUserID)
        
        do {
            let documentSnapshot = try await blockedByUserDoc.getDocument()
            DispatchQueue.main.async {
                self.isBlocked = documentSnapshot.exists
            }
        } catch {
            print("Error checking if blocked: \(error.localizedDescription)")
        }
    }
    
    func checkIfBlockedBy() async {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let blockedUserID = user.id else {
            return
        }
        
        let db = Firestore.firestore()
        
        let blockedByRef = db.collection("users").document(blockedUserID).collection("blockedUsers")
        let blockedByUserDoc = blockedByRef.document(currentUserUID)
        
        do {
            let documentSnapshot = try await blockedByUserDoc.getDocument()
            DispatchQueue.main.async {
                self.isBlockedBy = documentSnapshot.exists
            }
        } catch {
            print("Error checking if blocked: \(error.localizedDescription)")
        }
    }
    
    func unblock() {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let blockedUserID = user.id else {
            return
            return
        }
        isBlocked = false
        let db = Firestore.firestore()
        
        // Reference to the blockedBy collection for the blocked user
        let blockedByRef = db.collection("users").document(blockedUserID).collection("blockedBy")
        
        // Reference to the document in the blockedBy collection
        let blockedByUserDoc = blockedByRef.document(currentUserUID)
        
        // Delete the document from the blockedBy collection
        blockedByUserDoc.delete { error in
            if let error = error {
                print("Error unblocking user from blockedBy collection: \(error.localizedDescription)")
            } else {
                print("User with ID \(currentUserUID) unblocked by user with ID \(blockedUserID).")
            }
        }
        
        // Reference to the blockedUsers collection for the current user
        let blockedUsersRef = db.collection("users").document(currentUserUID).collection("blockedUsers")
        
        // Reference to the document in the blockedUsers collection
        let blockedUserDoc = blockedUsersRef.document(blockedUserID)
        
        // Delete the document from the blockedUsers collection
        blockedUserDoc.delete { error in
            if let error = error {
                print("Error removing user from blockedUsers collection: \(error.localizedDescription)")
            } else {
                print("User with ID \(blockedUserID) removed from blockedUsers collection.")
            }
        }
    }
    
    
    func block() {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let blockedUserID = user.id else {
            return
        }
        
        
        let db = Firestore.firestore()
        
        // Create a reference to the blockedBy collection for the blocked user
        let blockedByRef = db.collection("users").document(blockedUserID).collection("blockedBy")
        
        // Create a new document with the current user's ID as the document ID
        let blockedByUserDoc = blockedByRef.document(currentUserUID)
        
        // You can optionally set additional data in the document
        // For example, you can set a timestamp:
        let timestamp = Date()
        let data: [String: Any] = [
            "timestamp": timestamp
        ]
        
        // Set the data in the document
        blockedByUserDoc.setData(data) { error in
            if let error = error {
                print("Error creating blockedBy document: \(error.localizedDescription)")
            } else {
                print("Created blockedBy document with ID \(currentUserUID) in users.\(blockedUserID).blockedBy collection.")
            }
        }
        let blockedUsersRef = db.collection("users").document(currentUserUID).collection("blockedUsers")
        
        // Create a new document with the blocked user's ID as the document ID
        let blockedUserDoc = blockedUsersRef.document(blockedUserID)
        
        // You can optionally set additional data in the document
        // For example, you can set a timestamp:
        let timestamp1 = Date()
        let data1: [String: Any] = [
            "timestamp": timestamp1
        ]
        
        // Set the data in the document
        blockedUserDoc.setData(data1) { error in
            if let error = error {
                print("Error blocking user: \(error.localizedDescription)")
            } else {
                print("Blocked user with ID \(blockedUserID) added to blockedUsers collection.")
            }
        }
        
    }
    
}
