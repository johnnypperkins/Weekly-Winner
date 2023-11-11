//
//  groupService.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/23/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class groupService {
    private let db = Firestore.firestore()
    var authData: authenticationViewModel?
    init() {
        authData = nil
        Task{
            authData = await authenticationViewModel()
        }
    }
    
    func getPastRankedTickets(groupID: String, week: String, completion: @escaping ([Ticket]?, Error?) -> Void) {
        // Define date format and convert week string to Date
        print(week, " is week")
        print(groupID, "is groupID")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Month, Date
        guard let startDate = dateFormatter.date(from: week) else {
            completion(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Invalid week format"]))
            return
        }

        // Calculate the end date, which is one week later
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!

        print(startDate, endDate)
        // Construct the query
        let query = db.collectionGroup("pastWeekTickets")
            .whereField("groupID", isEqualTo: groupID)
            .whereField("dateCreated", isGreaterThanOrEqualTo: startDate)
            .whereField("dateCreated", isLessThanOrEqualTo: endDate)
            .order(by: "dateCreated", descending: false) // This must be the first order-by clause due to the inequality filter
            .order(by: "isEnabled", descending: true)
            .order(by: "totalWon", descending: true)


        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                print("PAST RANKED ERROR is \(error)")
                return
            }

            guard var documents = querySnapshot?.documents else {
                completion([], nil) // Empty array if no documents found
                print("ERROR 222")
                return
            }
            
            documents.sort { doc1, doc2 in
                let isEnabled1 = doc1.data()["isEnabled"] as? Bool ?? false
                let isEnabled2 = doc2.data()["isEnabled"] as? Bool ?? false

                let totalWon1 = doc1.data()["totalWon"] as? Int ?? 0
                let totalWon2 = doc2.data()["totalWon"] as? Int ?? 0

                if isEnabled1 != isEnabled2 {
                    return isEnabled1
                }

                return totalWon1 > totalWon2
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
                    //print("The index is \(index) and the total is \(total)")
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
                    //print("The index is \(index) and the total is \(total)")
                }
                
            }

            
            // Step 3: Fill the tickets array and assign ranks from ranksArray
            for (index, document) in documents.enumerated() {
                let data = document.data()
                var ticket = Ticket(
                    //id: document.documentID,
                    username: data["username"] as! String,
                    uid: data["uid"] as! String,
                    groupID: data["groupID"] as! String,
                    groupNumber: data["groupNumber"] as! Int,
                    dateCreated: data["dateCreated"] as! Timestamp,
                    totalWon: data["totalWon"] as! Int,
                    totalPotentialWon: data["totalPotentialWon"] as! Int,
                    groupName: data["groupName"] as! String,
                    rank: ranksArray[index], //data["rank"] as! String,
                    isEnabled: data["isEnabled"] as! Bool,
                    groupAdmin: data["groupAdmin"] as! String,
                    ticketFormat: data["ticketFormat"] as! [Int] // ticketformat99
                )
                if (abs(ticket.totalWon) > 0 || ticket.username == UserData.shared.username) || groupID != "Global" {
                    tickets.append(ticket)
                }
//                print("\(tickets) are tickets")
            }
            
            //tickets.sort { $0.totalWon > $1.totalWon }

            completion(tickets, nil)
        }

        // Rest of your code to execute the query and handle the results
    }

    
    func getCurrentRankedTickets(groupID: String, completion: @escaping ([Ticket]?, Int, Error?) -> Void) {
        let query = db.collectionGroup("currentWeekTickets")
            .whereField("groupID", isEqualTo: groupID)
            .order(by: "isEnabled", descending: true)
            .order(by: "totalWon", descending: true)
            .order(by: "totalPotentialWon", descending: true)
//            .limit(to: 100)

        //print("here at ranked docs")
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, 0, error)
                print("RANKED ERROR is \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                completion([],0, nil) // Empty array if no documents found
                print("ERROR 222")
                return
            }
            
            var tickets: [Ticket] = []
            var totalsArray: [Int] = []
            var enabledStatusArray: [Bool] = []
            var ranksArray: [String] = []
            var totalPlayers = 0

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
                    //print("The index is \(index) and the total is \(total)")
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
                    //print("The index is \(index) and the total is \(total)")
                }
                
            }

            
            // Step 3: Fill the tickets array and assign ranks from ranksArray
            for (index, document) in documents.enumerated() {
                let data = document.data()
                var ticket = Ticket(
                    //id: document.documentID,
                    username: data["username"] as! String,
                    uid: data["uid"] as! String,
                    groupID: data["groupID"] as! String,
                    groupNumber: data["groupNumber"] as! Int,
                    dateCreated: data["dateCreated"] as! Timestamp,
                    totalWon: data["totalWon"] as! Int,
                    totalPotentialWon: data["totalPotentialWon"] as! Int,
                    groupName: data["groupName"] as! String,
                    rank: ranksArray[index], //data["rank"] as! String,
                    isEnabled: data["isEnabled"] as! Bool,
                    groupAdmin: data["groupAdmin"] as! String,
                    ticketFormat: ["ticketFormat"] as? [Int] ?? [1,1,1] // ticketformat99
                )
                if (abs(ticket.totalPotentialWon) + abs(ticket.totalWon) > 0) || groupID != "Global" {
                    tickets.append(ticket)
                }
                totalPlayers+=1
//                print("\(tickets) are tickets")
            }
            
            completion(tickets,totalPlayers, nil)
        }
    }







    
    func createGroup(groupAdminUsername: String, groupName: String, groupSlogan: String, password: String?, ticketFormat: [Int], groupUrl: String, completion: @escaping (Result<String, Error>) -> Void) {
            
        guard let currentUser = Auth.auth().currentUser else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"])))
                    return
                }
        let time = Timestamp()
            var ref: DocumentReference? = nil
            ref = db.collection("groups").addDocument(data: [
                "groupName": groupName,
                "dateCreated": time,
                "groupImageURL": groupUrl,
                "groupSlogan": groupSlogan,
                "groupAdmin": currentUser.uid,
                "groupAdminUsername": groupAdminUsername,
                "password": password ?? NSNull(),
                "ticketFormat": ticketFormat
            ]) { err in
                if let err = err {
                                completion(.failure(err))
                } else {
                    guard let groupID = ref?.documentID else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve group ID"])))
                        return
                    }
                    self.db.collection("groups").document(groupID).collection("members").document(Auth.auth().currentUser!.uid).setData(["userID": currentUser.uid])
                    let group = Group(id: groupID, groupName: groupName, dateCreated: time, groupImageURL: groupUrl, groupSlogan: groupSlogan, groupAdmin: currentUser.uid, groupAdminUsername: groupAdminUsername, ticketFormat: ticketFormat)
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
                            let ticket = Ticket(username: UserData.shared.username, uid: Auth.auth().currentUser!.uid, groupID: group.id!, groupNumber: num!, dateCreated: Timestamp(date: Date()), totalWon: 0, totalPotentialWon: 0, groupName: group.groupName, rank: String(rank), isEnabled: enabled, groupAdmin: group.groupAdmin, ticketFormat: group.ticketFormat)
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
        let serialQueue = DispatchQueue(label: "com.yourapp.leaveGroup")
        var firstError: Error?

        serialQueue.async {
            let groupLeave = DispatchGroup()

            groupLeave.enter()
            db.collection("users").document(userID).collection("tickets").document("week").collection("currentWeekTickets").whereField("groupID", isEqualTo: ticket.groupID).getDocuments { (snapshot, error) in
                if let error = error {
                    firstError = firstError ?? error
                } else {
                    for doc in snapshot!.documents {
                        doc.reference.delete()
                    }
                }
                groupLeave.leave()
            }
            groupLeave.wait()

            groupLeave.enter()
            db.collection("users").document(userID).collection("bets").document("week").collection("currentWeekBets").whereField("groupID", isEqualTo: ticket.groupID).getDocuments() { (snapshot, error) in
                if let error = error {
                    firstError = firstError ?? error
                } else {
                    for document in snapshot!.documents {
                        document.reference.delete()
                    }
                }
                groupLeave.leave()
            }
            groupLeave.wait()

            groupLeave.enter()
            db.collection("groups").document(ticket.groupID).collection("members").document(userID).delete() { err in
                if let err = err {
                    firstError = firstError ?? err
                }
                groupLeave.leave()
            }
            groupLeave.wait()

            DispatchQueue.main.async {
                completion(firstError)
            }
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
                    //let id = document.documentID
                    let groupNumber = document.data()["groupNumber"] as? Int ?? 0 // default value if not found
                    let totalWon = document.data()["totalWon"] as? Int ?? 0 // default value if not found
                    let totalPotentialWon = document.data()["totalPotentialWon"] as? Int ?? 0 // default value if not found
                    let groupName = document.data()["groupName"] as? String ?? "null"
                    let groupID = document.data()["groupID"] as? String ?? "null"// default value if not found
                    let rank = document.data()["rank"] as? Int ?? -99
                    let isEnabled = document.data()["isEnabled"] as? Bool ?? false// default value if not found
                    let groupAdmin = document.data()["groupAdmin"] as? String ?? "null"// default value if not found
                    let ticketFormat = document.data()["ticketFormat"] as? [Int] ?? [1,1,1,1,1]// default value if not found
                    let dateCreated = document.data()["dateCreated"] as! Timestamp
                    
                    let ticket = Ticket(username: username, uid: userID, groupID: groupID, groupNumber: groupNumber, dateCreated: dateCreated, totalWon: totalWon, totalPotentialWon: totalPotentialWon, groupName: groupName, rank: String(rank), isEnabled: isEnabled, groupAdmin: groupAdmin, ticketFormat: ticketFormat)
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
