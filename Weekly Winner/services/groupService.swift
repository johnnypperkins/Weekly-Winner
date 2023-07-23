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
    var authData: authenticationViewModel?
    init() {
        authData = nil
        Task{
            authData = await authenticationViewModel()
        }
    }
    
    func getRankedTickets(groupN: String, completion: @escaping ([Group]?, Error?) -> Void) {
            let query = db.collectionGroup("groups")
                .whereField("groupName", isEqualTo: groupN)
                .order(by: "totalWon", descending: true)

            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([], nil) // Empty array if no documents found
                    return
                }

                var groups: [Group] = []

                for document in documents {
                    do {
                        if let group = try? document.data(as: Group.self, decoder: Firestore.Decoder()) {
                            groups.append(group)
                        } else {
                            print("Document does not exist or could not be parsed.")
                        }
                    } catch {
                        print("Error decoding document: \(error)")
                    }
                }

                completion(groups, nil)
            }
        }
    
    func uploadGroup(groupName: String, groupSlogan: String, password: String?, completion: @escaping (Result<String, Error>) -> Void) {
            
        guard let currentUser = Auth.auth().currentUser else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"])))
                    return
                }
        let time = Timestamp()
            var ref: DocumentReference? = nil
            ref = db.collection("groups").addDocument(data: [
                "groupName": groupName,
                "dateCreated": time,
                "groupImageURL": "",
                "groupSlogan": groupSlogan,
                "groupAdmin": currentUser.uid,
                "password": password ?? NSNull()
            ]) { err in
                if let err = err {
                                completion(.failure(err))
                } else {
                    guard let groupID = ref?.documentID else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve group ID"])))
                        return
                    }
                    self.db.collection("groups").document(groupID).collection("members").document(Auth.auth().currentUser!.uid).setData(["userID": currentUser.uid])
                    let ticket = Ticket(groupName: groupName, dateCreated: time, groupImageURL: "", groupSlogan: groupSlogan, groupAdmin: currentUser.uid)
                    self.joinGroup(userID: currentUser.uid, group: ticket)
                    
                    do {
                        Firestore.firestore().collection("groups").document(groupID).updateData(["keywordsForLookup": ticket.keywordsForLookup])
                    } catch let error {
                        print("Error updating data: \(error)")
                    }
                }
            }
        }
    func groupCount(userID: String, completion: @escaping (Int?, Error?) -> Void) {
        let db = Firestore.firestore()
        let userGroupsCollection = db.collection("users").document(userID).collection("groups")
        
        userGroupsCollection.getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }
            
            let groupCount = snapshot.documents.count
            completion(groupCount, nil)
        }
    }
    
    func getUsername() async -> String {
        return await authData?.username ?? ""
        }
    
    func joinGroup(userID: String, group: Ticket) {
        Task{
            let username = await self.getUsername() // Access the username asynchronously
            
            groupCount(userID: userID) { num, error in
                let db = Firestore.firestore()
                let userGroupsCollection = db.collection("users").document(userID).collection("groups")
                let group = Group(username: username, uid: Auth.auth().currentUser!.uid, groupID: group.id!, groupNumber: num!, totalWon: 0, totalPotentialWon: 0, groupName: group.groupName)
                do {
                    
                    let _ = try userGroupsCollection.addDocument(from: group) { error in
                        if let error = error {
                            print("Error uploading group: \(error)")
                        } else {
                            print("Group uploaded successfully!")
                        }
                    }
                } catch {
                    print("Error encoding group: \(error)")
                }
            }
        }
    }
    
    
    
    func fetchUserGroups(userID: String, completion: @escaping ([Group]?, Error?) -> Void) {
        Task{
            let username = await self.getUsername() // Access the username asynchronously
            
            db.collection("users").document(userID).collection("groups").getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    completion(nil, error)
                    return
                }
                
                var groups: [Group] = []
                
                for document in documents {
                    let id = document.documentID
                    let groupNumber = document.data()["groupNumber"] as? Int ?? 0 // default value if not found
                    let totalWon = document.data()["totalWon"] as? Int ?? 0 // default value if not found
                    let totalPotentialWon = document.data()["totalPotentialWon"] as? Int ?? 0 // default value if not found
                    let groupName = document.data()["groupName"] as? String ?? "null"
                    let groupID = document.data()["groupID"] as? String ?? "null"// default value if not found
                    
                    let group = Group(id: id, username: username, uid: userID, groupID: groupID, groupNumber: groupNumber, dateCreated: "today", totalWon: totalWon, totalPotentialWon: totalPotentialWon, groupName: groupName)
                    groups.append(group)
                }
                
                // sorts them based on groupNum
                groups.sort { $0.groupNumber < $1.groupNumber }
                
                completion(groups, nil)
            }
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
            .whereField("groupNumber", isEqualTo: groupNumber)
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
