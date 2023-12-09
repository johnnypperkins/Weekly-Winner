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
    private let service = userService()
    @Published var isBlocked: Bool = false
    @Published var isBlockedBy: Bool = false
    @Published var user: User
    @Published var stats: Stats? = nil
    @Published var profileImageURLHolder: String
    
    init(user: User) {
        //self.getCountOfStringsInArrayField(user1: user)
        self.user = user
        self.profileImageURLHolder = user.profileImageUrl
        //self.isFollow = uService.isFollowed(id: user.id!)
        fetchStats(uid: user.id!) {statistics in
            self.stats = statistics
            print("sdfsdfsdfsdfsdfsdfsd \(statistics)")
        }
        Task{
            await self.checkIfBlocked()
            await self.checkIfBlockedBy()
        }
        print(user.isCurrentUser)
        //self.fetchLikedTweets()
    }
    
    func fetchStats(uid: String, completion: @escaping (Stats?) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("Misc")
            .document("stats")
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let snapshot = snapshot else {
                    print("Snapshot is nil.")
                    completion(nil)
                    return
                }

                if snapshot.exists {
                    let id = snapshot.documentID
                    let data = snapshot.data() as? [String: Any] ?? [:]

                    let avgOddsPlaced = data["avgOddsPlaced"] as? Double ?? 0
                    let betScore = data["betScore"] as? Double ?? 0
                    let totalBetsPlaced = data["totalBetsPlaced"] as? Int ?? 0
                    let totalBetsWon = data["totalBetsWon"] as? Int ?? 0

                    let statistics = Stats( avgOddsPlaced: avgOddsPlaced, betScore: betScore, totalBetsPlaced: totalBetsPlaced, totalBetsWon: totalBetsWon)
                    completion(statistics)
                } else {
                    print("Document does not exist.")
                    completion(nil)
                }
            }
    }



    
    func fetchUser() {
            guard let uid = user.id else { return }
            
        service.fetchUser(uid: uid) { user,success  in
            self.user = user!
            self.profileImageURLHolder = user!.profileImageUrl
            }
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
