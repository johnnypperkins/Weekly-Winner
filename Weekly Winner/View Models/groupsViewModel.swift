//
//  groupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/16/23.
//
import Firebase


class groupsViewModel: ObservableObject {
    
    @Published var queriedGroups: [Group] = [] // Group99
    @Published var userTickets: [Ticket] = [] // Ticket99
    @Published var rankedGroupTickets: [Ticket] = [] // Ticket99
    
    @Published var canJoinGroup: Bool = true
    @Published var groupsFetched = false
    @Published var groupAdmin = ""
    private let grpService = groupService()
    
    private let db = Firestore.firestore()
    
    // In ViewModel

//    var rankedGroupTickets: [(rank: String, ticket: Ticket)] {
//        var lastScore: Double? = nil
//        var currentRank: Int = 1
//        var increaseRank: Bool = true
//        var rankedTickets: [(rank: String, ticket: Ticket)] = []
//
//        for ticket in tickets.sorted(by: { $0.totalWon > $1.totalWon }) {
//            if let lastScore = lastScore, lastScore == ticket.totalWon {
//                increaseRank = false
//            } else {
//                if !increaseRank {
//                    currentRank += 1
//                }
//                increaseRank = true
//            }
//
//            let displayRank = increaseRank ? String(currentRank) : "T\(currentRank)"
//            rankedTickets.append((rank: displayRank, ticket: ticket))
//            lastScore = ticket.totalWon
//        }
//        return rankedTickets
//    }

    
    init() {
        fetchUserTickets() {
            self.groupsFetched = true
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
    
    func updateIsEnabled(ticket: Ticket, isEnabled: Bool, completion: @escaping (Error?) -> Void) {
        // Assuming you have already initialized Firebase with appropriate configurations
        
        let db = Firestore.firestore()
        let ticketDocRef = db.collection("users").document(ticket.uid).collection("tickets").document("week").collection("currentWeekTickets").document(ticket.id!)
        
        ticketDocRef.updateData(["isEnabled": isEnabled]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func getGroupAdmin(groupID: String) {
            let db = Firestore.firestore()
            let docRef = db.collection("groups").document(groupID)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().flatMap(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    if let groupAdmin = document.get("groupAdmin") as? String {
                        self.groupAdmin = groupAdmin
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    
    func fetchGroup(from keyword: String) {
        db.collection("groups").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedGroups = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Group.self) // Group99
            }
            print("here")
        }
        print("hereeeee")
    }
    
    func fetchRankedTickets(groupID: String, completion: @escaping () -> Void){
        grpService.getRankedTickets(groupID: groupID) { [weak self] (tickets, error) in
                if let error = error {
                    // Handle error
                    print("Error fetching groups: \(error)")
                } else if let tickets = tickets {
                    DispatchQueue.main.async {
                        self?.rankedGroupTickets = tickets
                        //print(tickets)
                        print("test print")
                    }
                }
            }
        }
    
    func joinGroup(group: Group) { // Group99
        
        grpService.joinGroup(userID: Auth.auth().currentUser!.uid, group: group){ error in
            self.fetchUserTickets() {
                print(self.userTickets)
            }
        }
    }
    
    func checkIfGroupAlreadyJoined(group: Group, completion: @escaping (Bool) -> Void) {
        self.fetchUserTickets() {
            for groupsJoined in self.userTickets {
                if group.id == groupsJoined.groupID {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }


    func fetchUserTickets(completion: @escaping () -> Void) {
        print("Fetch started")
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let ticketsCollection = db.collection("users").document(currentUser.uid).collection("tickets").document("week").collection("currentWeekTickets")
        
        ticketsCollection.order(by: "groupNumber").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching groups: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, error == nil else { return }
            
            self.userTickets = documents.compactMap { snapshot in
                print(snapshot)
                return try? snapshot.data(as: Ticket.self) // Ticket99
            }
            print("tickets: \(userTickets)")

            // Call the completion closure after fetching and processing
            completion()
        }
    }
    
    func leaveGroup(ticket: Ticket, completion: @escaping () -> Void) {
        // Get a reference to Firestore and the current user
        guard let currentUser = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
        grpService.leaveGroup(ticket: ticket, userID: currentUser) { error in
            self.fetchUserTickets() {
                
            }
        }

        
        func deleteGroupIfNeeded(groupID: String) {
            db.collection("groups").document(groupID).getDocument { document, error in
                if let error = error {
                    print("Error fetching group: \(error.localizedDescription)")
                    return
                }
                guard let document = document, document.exists, let members = document.get("members") as? [String] else {
                    // If the group still has members, we don't delete it.
                    return
                }
                print("Members: \(members)") // Debug line
                print("Members count: \(members.count)") // Debug line
                if members.isEmpty {
                    // If no members left, delete the group.
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting group: \(error.localizedDescription)")
                        } else {
                            print("Group successfully deleted!")
                        }
                    }
                }
            }
        }
    }
    
    
}
