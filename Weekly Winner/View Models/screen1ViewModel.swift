//
//  screen1ViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 12/17/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFunctions


class screen1ViewModel: ObservableObject {
    
    private let serviceUSER = userService()
    private let serviceGROUP = groupService()
    
    @Published var userSession : FirebaseAuth.User? = nil
    @Published var updateURL: String = ""
    @Published var userGroups: [Group] = []
    @Published var canGetHistoricalData = false
    @Published var userGroupsLoaded = false
    @Published var currentUser: User? = nil
    private let currentVersion: String = "2.1.0"
    
    @Published var canFetchDailyRankedTickets = false
    @Published var canFetchWeeklyRankedTickets = false
    
    @Published var friendsUIDS: [String] = []

    @Published var userAnnouncements: [Announcement] = []

    
    init() {
        self.userSession = Auth.auth().currentUser
        self.setStaticUser {
            
            self.fetchUserCoinsAndBucks(userID: Auth.auth().currentUser?.uid ?? "") {}
        }
        self.fetchUserGroups {}
        
        fetchUserTickets(timeFrame: "daily") {
            self.fetchCurrentRankedTickets(groupID: "GlobalDaily", timeFrame: "daily") {
            }
        }
        self.importFriends()


    }
    
    
    func importFriends() {
        // Clear any existing data in friends
        self.friendsUIDS.removeAll()
        
        // Initialize Firestore reference
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // Access the 'friends' subcollection for the user
        let friendsCollection = db.collection("users").document(uid).collection("friends")
        
        // Fetch all documents within the 'friends' subcollection
        friendsCollection.getDocuments { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, error == nil else {
                print("Error fetching friends documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Extract the UIDs of the friends from the document IDs
            let friendUIDs = querySnapshot.documents.map { $0.documentID }
            self.friendsUIDS = friendUIDs
        }
    }

    func setUserFCM(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        print("this is fcmToken: \(StaticUserData.fcmToken)")
        if StaticUserData.fcmToken != "" {
            print("this is fcm token: \(StaticUserData.fcmToken)")
            userRef.setData(["fcmToken": StaticUserData.fcmToken], merge: true) { error in
                if let error = error {
                    print("Error setting user FCM token: \(error.localizedDescription)")
                    completion()
                } else {
                    print("User FCM token successfully set.")
                    completion()
                }
            }
        } else {
            print("cant set sorry")
        }
        
    }

    
    func fetchUserAnnouncements(userID: String, completion: @escaping () -> Void) {
        self.userAnnouncements.removeAll()

        let db = Firestore.firestore()
        let announcementsRef = db.collection("users").document(userID).collection("Misc").document("announcements").collection("announcementCollection")
        //users/fg57TZhmLmWH9TT3WCA3WuXT7dy2/Misc/announcements/announcementCollection/xJKBZ69o5nmPtIzNFO2h

        announcementsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion()
            }
            
            if let documents = querySnapshot?.documents {
                for doc in querySnapshot!.documents {
                    let data = doc.data()
                    if let status = data["status"] as? String,
                        let description = data["description"] as? String,
                        let announcementType = data["announcementType"] as? String,
                       let timestamp = data["timestamp"] as? Timestamp
                    {
                        
                        let announcement = Announcement(status: status, description: description, announcementType: announcementType, timestamp: timestamp)
                        print("ANn'oun: \(announcement)")
                        self.userAnnouncements.append(announcement)
                    } else {
                        print("wrong fields")
                    }
                }
            }
            self.userAnnouncements.sort(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            print("ANNOubc: \(self.userAnnouncements)")
            completion()
        }
    }
    
    func setAllAnnouncementsToSeen(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let announcementsRef = db.collection("users").document(userID).collection("Misc").document("announcements").collection("announcementCollection")

        announcementsRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching documents: \(String(describing: error))")
                completion()
                return
            }
            
            // Check if there are any documents to update
            guard !documents.isEmpty else {
                print("No documents found to update.")
                completion()
                return
            }

            let batch = db.batch()
            
            for document in documents {
                let docRef = announcementsRef.document(document.documentID)
                batch.updateData(["status": "seen"], forDocument: docRef)
            }
            
            // Commit the batch
            batch.commit { err in
                if let err = err {
                    print("Error updating documents: \(err)")
                } else {
                    print("All documents successfully updated")
                }
                completion()
            }
        }
    }

    
    func fetchUserCoinsAndBucks(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let poolCoins = data?["poolCoins"] as? Double
                let poolBucks = data?["poolBucks"] as? Double
                StaticUserData.shared.currentUser.poolBucks = poolBucks ?? -99
                StaticUserData.shared.currentUser.poolCoins = poolCoins ?? -99
                completion()
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }


    
    func setStaticUser(completion: @escaping () -> Void) {
        
        guard let uid = self.userSession?.uid else { return }
        
        serviceUSER.fetchUser(uid: uid) { user,success  in
            StaticUserData.shared.currentUser = user!
            self.currentUser = user!
        }
    }
    
    func setCoins(userID: String) {
        // /users/userID
        // field called "poolCoins" and "poolBucks"
    }
    
    func forceUpdate(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let updatesDocument = db.collection("Misc").document("updates")
        
        updatesDocument.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion()
                return
            }
            
            guard let document = document, document.exists,
                  let version = document["version"] as? String,
                  let appleInTestingStage = document["appleCanTest"] as? Bool,
                  let updateURL2 = document["updateURL"] as? String else {
                print("Document not found or fields missing")
                completion()
                return
            }
        print("DATABASE VERSION", version)
        print("IOS VERSION", self.currentVersion)
            
        if self.currentVersion != version && appleInTestingStage == false {
                self.updateURL = updateURL2
                completion()
            } else {
                completion()
            }
        }
    }
    
    func fetchUserGroups(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        serviceGROUP.fetchUserGroups() { groups, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else {
                self.userGroups = groups ?? []
                self.canGetHistoricalData = true
                self.userGroupsLoaded = true
            }
        }
    }
    
    func fetchCurrentRankedTickets(groupID: String, timeFrame: String, completion: @escaping () -> Void){
        serviceGROUP.getCurrentRankedTickets(groupID: groupID, timeFrame: timeFrame) { tickets, totalPlayers, error in
                if let error = error {
                    print("Error fetching user groups: \(error.localizedDescription)")
                } else if let tickets = tickets {
                    if timeFrame == "daily" {
                        StaticUserData.shared.dailyRankedTickets = tickets
                        self.canFetchDailyRankedTickets = true
                    } else if timeFrame == "weekly" {
                        StaticUserData.shared.weeklyRankedTickets = tickets
                        self.canFetchWeeklyRankedTickets = true
                    }
//                    print("ABCD", tickets)
//                        print("test print")
                    }
                completion()
            }
        }
    
    func fetchUserTickets(timeFrame: String, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        serviceGROUP.fetchUserTickets(userID: userId, timeFrame: timeFrame) { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                if timeFrame == "weekly" {
                    StaticUserData.shared.weeklyTicket = tickets[0]
                } else if timeFrame == "daily" {
                    StaticUserData.shared.dailyTicket = tickets[0]

                }
            }
            completion()
        }
    }
    

    
    
}

func fetchUserProfilePic(uid: String, completion: @escaping (String?, Error?) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(uid)

    userRef.getDocument { (documentSnapshot, error) in
        if let error = error {
            print("Error checking if blocked: \(error.localizedDescription)")
            completion(nil, error)
        } else {
            let profileImageUrl = documentSnapshot?.data()?["profileImageUrl"] as? String
            completion(profileImageUrl, nil)
        }
    }
}


func staticSendNotification(token: String, message: String, completion: @escaping () -> Void) {
    let functions = Functions.functions()
    functions.httpsCallable("sendUserNotification").call(["token": token, "message": message]) { result, error in
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
                print("Error: \(code) \(message) \(String(describing: details))")
            }
            // Handle the error
            print("Function call failed: \(error.localizedDescription)")
            return
        }
        // If we have a result, process it here
        print("Function result: \(String(describing: result?.data))")
    }
}

//func staticfetchUser(uid: String, completion: @escaping (String?) -> Void) {
//    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
//        guard let snapshot = snapshot else {
//            completion(nil) // Return false if there's an issue with document retrieval
//            return
//        }
//        
//        if let user = try? snapshot.data(as: User.self) {
//            completion(user) // Return true and the user object if successfully retrieved
//        } else {
//            completion(nil) // Return false if there's an issue converting data to User
//        }
//    }
//}

func fetchUserFCMToken(uid: String, completion: @escaping (String?) -> Void) {
    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
        guard let snapshot = snapshot, snapshot.exists else {
            completion(nil) // Return nil if there's an issue with document retrieval or it doesn't exist
            return
        }

        if let fcmToken = snapshot.get("fcmToken") as? String {
            completion(fcmToken) // Return the fcmToken if successfully retrieved
        } else {
            completion(nil) // Return nil if the fcmToken field is missing or not a string
        }
    }
}
