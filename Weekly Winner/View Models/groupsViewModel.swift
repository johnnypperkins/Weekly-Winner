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
    @Published var joinedGroups: [Group] = []
    @Published var totalArrayOfDates: [[String]] = []
    @Published var canGetHistoricalData: Bool = false
    
    @Published var canJoinGroup: Bool = true
    @Published var groupsFetched = false
    @Published var groupAdmin = ""
    private let grpService = groupService()
    
    private let db = Firestore.firestore()

    
    init() {
        fetchUserTickets() {
            self.groupsFetched = true
            self.fetchUserGroups {
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
    
    
    func printTicket(ticket: Ticket) {
        print(ticket)
        print("single debugger")
    }
    func printTickets(ticket: [Ticket]) {
        print(ticket)
        print("multi debugger")
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
//                    DispatchQueue.main.async {
                        self?.rankedGroupTickets = tickets
                        print(tickets)
                        print("test print")
                    }
//                }
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
            
            
            
            // Call the completion closure after fetching and processing
            completion()
        }
    }
    
    func fetchUserGroups(completion: @escaping () -> Void) {
        let groupsCollection = db.collection("groups")
        let groupIDs = self.userTickets.map { $0.groupID }
        totalArrayOfDates.removeAll()
        
        let dispatchGroup = DispatchGroup() // to manage multiple asynchronous tasks
        
        for groupID in groupIDs {
            dispatchGroup.enter() // enter group for each groupID
            
            groupsCollection.document(groupID).getDocument { groupSnapshot, groupError in
                if let groupError = groupError {
                    print("Error fetching group: \(groupError.localizedDescription)")
                    dispatchGroup.leave() // leave group on failure
                    return
                }
                
                guard let groupSnapshot = groupSnapshot, let data = groupSnapshot.data() else {
                    print("Snapshot does not exist or is nil")
                    dispatchGroup.leave() // leave group if data is nil
                    return
                }

                if let groupName = data["groupName"] as? String,
                   let dateCreated = data["dateCreated"] as? Timestamp,
                   let groupImageURL = data["groupImageURL"] as? String,
                   let groupSlogan = data["groupSlogan"] as? String,
                   let groupAdmin = data["groupAdmin"] as? String,
                   let ticketFormat = data["ticketFormat"] as? [Int] {
                    
                    self.totalArrayOfDates.append(self.populateArrayOfDates(from: dateCreated))
                    
                    let password = data["password"] as? String
                    
                    let group = Group(id: groupSnapshot.documentID,
                                      groupName: groupName,
                                      dateCreated: dateCreated,
                                      groupImageURL: groupImageURL,
                                      groupSlogan: groupSlogan,
                                      groupAdmin: groupAdmin,
                                      password: password,
                                      ticketFormat: ticketFormat)
                    
                    self.joinedGroups.append(group)
                } else {
                    print("Failed to extract data for groupID: \(groupID)")
                }
                self.canGetHistoricalData = true
                print("THIS IS FAJLAFJSLD", self.totalArrayOfDates)
                dispatchGroup.leave() // leave group on success
            }
        }
        
        
        dispatchGroup.notify(queue: .main) {
            print("GROUPSSSS")
            print(self.joinedGroups)
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
    
    func populateArrayOfDates(from timestamp: Timestamp) -> [String] {
        
        var smallArr: [String] = []
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, d" // Month, Date

        // Convert Firestore Timestamp to Date
        var currentMonday = timestamp.dateValue()

        // Find the most recent Monday (including today if it's a Monday)
        var mostRecentMonday = Date()
        while calendar.component(.weekday, from: mostRecentMonday) != 2 { // 2 corresponds to Monday
            mostRecentMonday = calendar.date(byAdding: .day, value: -1, to: mostRecentMonday)!
        }

        // If currentMonday is not a Monday, find the previous Monday
        if calendar.component(.weekday, from: currentMonday) != 2 {
            while calendar.component(.weekday, from: currentMonday) != 2 { // 2 corresponds to Monday
                currentMonday = calendar.date(byAdding: .day, value: -1, to: currentMonday)!
            }
        }

        // Iterate through the Mondays until the most recent Monday
        while currentMonday <= mostRecentMonday {
            if currentMonday == mostRecentMonday {
                smallArr.append("current week")
            } else {
                smallArr.append(dateFormatter.string(from: currentMonday))
            }

            // Add 7 days to find the next Monday
            currentMonday = calendar.date(byAdding: .day, value: 7, to: currentMonday)!
        }
        if smallArr.count > 0 {
            smallArr.remove(at: smallArr.count-1)
            smallArr.append("Current Week")
        }
        smallArr.reverse()
        print("Dates: \(smallArr)")
        
        return smallArr
    }
    
}


