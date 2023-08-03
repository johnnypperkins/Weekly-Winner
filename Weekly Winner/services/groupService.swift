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
    
    func getRankedTickets(groupID: String, completion: @escaping ([Ticket]?, Error?) -> Void) {
        let query = db.collectionGroup("currentWeekTickets")
            .whereField("groupID", isEqualTo: groupID)
            .order(by: "isEnabled", descending: true)
            .order(by: "totalWon", descending: true)

        //print("here at ranked docs")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                print("ERRRROR is \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                completion([], nil) // Empty array if no documents found
                print("ERROR 222")
                return
            }
            
            var tickets: [Ticket] = []
            var totalsArray: [Int] = []
            var enabledStatusArray: [Bool] = []
            var ranksArray: [String] = []

            // Step 1: Fill the totalsArray with all totals
            for document in documents {
                let data = document.data()
                let totalWon = data["totalWon"] as! Int
                let isEnabled = data["isEnabled"] as! Bool
                totalsArray.append(totalWon)
                enabledStatusArray.append(isEnabled)
            }

            // Step 2: Create ranksArray based on totalsArray
            var lastTotal = Int.max
            var rank = 0
            var tieCount = 1
            for (index, total) in totalsArray.enumerated() {
                if enabledStatusArray[index] == true {
                    if total == lastTotal {
                        tieCount += 1
                        ranksArray[ranksArray.count - 1] = "T\(rank)"
                        ranksArray.append("T\(rank)")
                    } else {
                        rank += tieCount
                        tieCount = 1
                        ranksArray.append("\(rank)")
                        lastTotal = total
                    }
                    print("The index is \(index) and the total is \(total)")
                }
                
            }
            tieCount = 1
            lastTotal = Int.max
            
            for (index, total) in totalsArray.enumerated() {
                if enabledStatusArray[index] == false {
                    if total == lastTotal {
                        tieCount += 1
                        ranksArray[ranksArray.count - 1] = "T\(rank)"
                        ranksArray.append("T\(rank)")
                    } else {
                        rank += tieCount
                        tieCount = 1
                        ranksArray.append("\(rank)")
                        lastTotal = total
                    }
                    print("The index is \(index) and the total is \(total)")
                }
                
            }

            
            // Step 3: Fill the tickets array and assign ranks from ranksArray
            for (index, document) in documents.enumerated() {
                let data = document.data()
                var ticket = Ticket(
                    id: document.documentID,
                    username: data["username"] as! String,
                    uid: data["uid"] as! String,
                    groupID: data["groupID"] as! String,
                    groupNumber: data["groupNumber"] as! Int,
                    dateCreated: data["dateCreated"] as! String,
                    totalWon: data["totalWon"] as! Int,
                    totalPotentialWon: data["totalPotentialWon"] as! Int,
                    groupName: data["groupName"] as! String,
                    rank: ranksArray[index], //data["rank"] as! String,
                    isEnabled: data["isEnabled"] as! Bool,
                    groupAdmin: data["groupAdmin"] as! String
                )
                tickets.append(ticket)
                print("\(tickets) are tickets")
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
        let userGroupsCollection = db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets")
        
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
                            let userTicketsCollection = db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets")
                            let ticket = Ticket(username: UserData.shared.username, uid: Auth.auth().currentUser!.uid, groupID: group.id!, groupNumber: num!, totalWon: 0, totalPotentialWon: 0, groupName: group.groupName, rank: String(rank), isEnabled: enabled, groupAdmin: group.groupAdmin)
                            do {
                                let _ = try userTicketsCollection.addDocument(from: ticket) { error in
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
        db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets").whereField("groupID", isEqualTo: ticket.groupID).getDocuments { (snapshot, error) in
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
        db.collection("users").document(userID).collection("bets").document("week").collection("currentWeekBets").whereField("groupID", isEqualTo: ticket.groupID).getDocuments() { (snapshot, error) in
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
            
            db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets").getDocuments { querySnapshot, error in
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
                    let groupAdmin = document.data()["groupAdmin"] as? String ?? "null"// default value if not found
                    
                    let ticket = Ticket(id: id, username: username, uid: userID, groupID: groupID, groupNumber: groupNumber, dateCreated: "today", totalWon: totalWon, totalPotentialWon: totalPotentialWon, groupName: groupName, rank: String(rank), isEnabled: isEnabled, groupAdmin: groupAdmin)
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
        db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets")
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
