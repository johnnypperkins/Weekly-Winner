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
    
    func getRankedTickets(groupID: String, completion: @escaping ([Ticket]?, Error?) -> Void) { // Ticket99
            let query = db.collectionGroup("groups")
                .whereField("groupID", isEqualTo: groupID)
                .order(by: "isEnabled", descending: true)
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

                var tickets: [Ticket] = [] // Ticket99

                for document in documents {
                    do {
                        if let ticket = try? document.data(as: Ticket.self, decoder: Firestore.Decoder()) { // Ticket99
                            tickets.append(ticket)
                        } else {
                            print("Document does not exist or could not be parsed.")
                        }
                    } catch {
                        print("Error decoding document: \(error)")
                    }
                }

                completion(tickets, nil)
            }
        }
    
    func createGroup(groupName: String, groupSlogan: String, password: String?, completion: @escaping (Result<String, Error>) -> Void) {
            
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
                    let group = Group(id: groupID, groupName: groupName, dateCreated: time, groupImageURL: "", groupSlogan: groupSlogan, groupAdmin: currentUser.uid)
                    self.joinGroup(userID: currentUser.uid, group: group){error in
                        
                    }
                        
                    
                    do {
                        Firestore.firestore().collection("groups").document(groupID).updateData(["keywordsForLookup": group.keywordsForLookup])
                    } catch let error {
                        print("Error updating data: \(error)")
                    }
                }
            }
        }
    
    func ticketCount(userID: String, completion: @escaping (Int?, Error?) -> Void) {
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
            
            let ticketCount = snapshot.documents.count
            completion(ticketCount, nil)
        }
    }
    
    func getUsername() async -> String {
        return await authData?.username ?? ""
        }
    
    func joinGroup(userID: String, group: Group, completion: @escaping (Error?) -> Void) {
        Task {
            let username = await self.getUsername() // Access the username asynchronously
            var enabled = false
            ticketCount(userID: userID) { num, error in
                if group.groupAdmin == userID {
                    enabled = true
                }
                let db = Firestore.firestore()
                db.collection("groups").document(group.id!).collection("members").getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let rank = (snapshot?.documents.count)! + 1 ?? -99
                        let userGroupsCollection = db.collection("users").document(userID).collection("groups")
                        let ticket = Ticket(username: username, uid: Auth.auth().currentUser!.uid, groupID: group.id!, groupNumber: num!, totalWon: 0, totalPotentialWon: 0, groupName: group.groupName, rank: String(rank), isEnabled: enabled)
                        do {
                            let _ = try userGroupsCollection.addDocument(from: ticket) { error in
                                if let error = error {
                                    print("Error uploading group: \(error)")
                                } else {
                                    print("Joined group successfully!")
                                    self.db.collection("groups").document(group.id!).collection("members").document(Auth.auth().currentUser!.uid).setData(["userID": userID])
                                }
                            }
                        } catch {
                            print("Error encoding group: \(error)")
                        }
                        completion(error)
                    }
                }
            }
            completion(nil)
        }
    }



    func leaveGroup(ticket: Ticket, userID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        // Create a dispatch group to synchronize your async calls
        let groupLeave = DispatchGroup()
        
        // Enter the group
        groupLeave.enter()
        db.collection("users").document(userID).collection("groups").whereField("groupID", isEqualTo: ticket.groupID).getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for doc in snapshot!.documents {
                    doc.reference.delete()
                }
                // Leave the group after finishing
                groupLeave.leave()
            }
        }

        // Enter the group
        groupLeave.enter()
        db.collection("users").document(userID).collection("bets").whereField("groupID", isEqualTo: ticket.groupID).getDocuments() { (snapshot, error) in
            if let error = error {
                completion(error)
            } else {
                for document in snapshot!.documents {
                    document.reference.delete()
                }
                // Leave the group after finishing
                groupLeave.leave()
            }
        }

        // Enter the group
        groupLeave.enter()
        db.collection("groups").document(ticket.groupID).collection("members").document(userID).delete() { err in
            if let err = err {
                completion(err)
            } else {
                // Leave the group after finishing
                groupLeave.leave()
            }
        }

        // Call completion when all tasks are done
        groupLeave.notify(queue: .main) {
            completion(nil)
        }
    }

    
    
    
    func fetchUserTickets(userID: String, completion: @escaping ([Ticket]?, Error?) -> Void) { // Ticket99
        Task{
            let username = await self.getUsername() // Access the username asynchronously
            
            db.collection("users").document(userID).collection("groups").getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    completion(nil, error)
                    return
                }
                
                var tickets: [Ticket] = [] // Ticket99
                
                for document in documents {
                    let id = document.documentID
                    let groupNumber = document.data()["groupNumber"] as? Int ?? 0 // default value if not found
                    let totalWon = document.data()["totalWon"] as? Int ?? 0 // default value if not found
                    let totalPotentialWon = document.data()["totalPotentialWon"] as? Int ?? 0 // default value if not found
                    let groupName = document.data()["groupName"] as? String ?? "null"
                    let groupID = document.data()["groupID"] as? String ?? "null"// default value if not found
                    let rank = document.data()["rank"] as? Int ?? -99
                    let isEnabled = document.data()["isEnabled"] as? Bool ?? false// default value if not found
                    
                    let ticket = Ticket(id: id, username: username, uid: userID, groupID: groupID, groupNumber: groupNumber, dateCreated: "today", totalWon: totalWon, totalPotentialWon: totalPotentialWon, groupName: groupName, rank: String(rank), isEnabled: isEnabled)
                    tickets.append(ticket) // Ticket99
                }
                
                // sorts them based on groupNum
                tickets.sort { $0.groupNumber < $1.groupNumber }
                
                completion(tickets, nil)
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
