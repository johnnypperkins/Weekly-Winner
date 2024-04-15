//
//  groupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/16/23.
//
import Firebase
import FirebaseFirestore


class groupsViewModel: ObservableObject {
    
    @Published var queriedGroups: [Group] = [] // Group99
    @Published var userTickets: [Ticket] = [] // Ticket99
    @Published var currentRankedGroupTickets: [Ticket] = [] // Ticket99
    @Published var pastRankedGroupTickets: [Ticket] = [] // Ticket99
    @Published var joinedGroups: [Group] = []
    @Published var userGroups: [Group] = []
    @Published var canGetHistoricalData: Bool = false
    @Published var totalArrayOfDates: [[String]] = []
    @Published var userGroupsLoaded: Bool = false
    @Published var totalPlayers: Int = 0
    @Published var canJoinGroup: Bool = true
    @Published var groupsFetched = false
    @Published var groupAdmin = ""
    @Published var weekIndex = -99
    @Published var dayIndex = -99
    @Published var friendsTickets: [Ticket] = []
    @Published var friendsList: [String] = []
    
    private let groupService = GroupService()
    
    private let db = Firestore.firestore()

    
    init() {
        loadInfo()
    }
    
    func loadInfo() {
        self.fetchFriendsList()
            self.groupsFetched = true
            self.fetchUserGroups {
                self.userGroupsLoaded = true
                self.totalArrayOfDates.append(self.populateArrayOfDates(from: Timestamp(date: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 22))!))) //weekly
                self.totalArrayOfDates.append(self.loadPastDailyTicketDates(from: Timestamp(date: Calendar.current.date(from: DateComponents(year: 2023, month: 12, day: 13))!))) // daily
            }
    }
    
    func fetchFriendsList() {
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("friends").getDocuments { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self?.friendsList = querySnapshot!.documents.map { $0.documentID }
                    self?.filterFriendsTickets()
                }
            }
        }
        
        func filterFriendsTickets() {
            // Assuming StaticUserData.shared.dailyRankedTickets exists and is accessible
            friendsTickets = StaticUserData.shared.dailyRankedTickets.filter { ticket in
                self.friendsList.contains(where: { $0 == ticket.uid })
            }
        }
    
    func uploadGroupImage(_ image: UIImage, group: Group, completion: @escaping (String) -> Void) {
        print("entered1")
        guard let user = Auth.auth().currentUser else { return }
        print("entered01")
        imageUploader.uploadImage(use: "group", image: image) { imageURL in
            print("entered2")
            Firestore.firestore().collection("groups").document(group.id!).updateData(["groupImageURL": imageURL]) { error in
                print("entered3")
                if error == nil {
                    completion(imageURL)
                } else {
                    // Handle the error accordingly
                    print("Error updating the profile image URL: \(error?.localizedDescription ?? "No error description")")
                }
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
    
    func fetchCurrentRankedTickets(groupID: String, timeFrame: String, completion: @escaping () -> Void){
        groupService.getCurrentRankedTickets(groupID: groupID, timeFrame: "daily") { [weak self] (tickets, totalPlayers, error) in
                if let error = error {
                    // Handle error
                    //print("Error fetching groups CURRENT: \(error)")
                } else if let tickets = tickets {
//                    DispatchQueue.main.async {
                        self?.currentRankedGroupTickets = tickets
                        //self?.totalPlayers = totalPlayers
                        //self?.weekIndex = totalArrayOfDates[0].count
                    if timeFrame == "daily" {
                        StaticUserData.shared.dailyRankedTickets = tickets
                    } 
//                    else if timeFrame == "weekly" {
//                        StaticUserData.shared.weeklyRankedTickets = tickets
//                    }
                        //print(tickets)
                        print("test print")
                    }
//                }
            }
        }
    
    func fetchPastRankedTickets(groupID: String, week: String, timeFrame: String, completion: @escaping () -> Void) {
        groupService.getPastRankedTickets(groupID: groupID, week: week, timeFrame: "daily") { [weak self] (tickets, error) in
                if let error = error {
                    // Handle error
                    print("Error fetching groups PAST: \(error)")
                    print(error.localizedDescription)
                } else if let tickets = tickets {
//                    DispatchQueue.main.async {
                        self?.pastRankedGroupTickets = tickets
                      //  print("THESE ARE TICKETS \(tickets)")
                        print("test print")
                    }
//                }
            }
    }
    
    
    func fetchUserTickets(timeFrame: String, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupService.fetchUserTickets(userID: userId, timeFrame: "daily") { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                self.userTickets = tickets
            }
            completion()
        }
    }
  
    func fetchGroups(array1: [Ticket], completion: @escaping () -> Void) {
       
        let array = array1.sorted { $0.groupNumber < $1.groupNumber }
        
        // Firestore reference to the "groups" collection
        let groupsRef = Firestore.firestore().collection("groups")

        // Initialize an empty array to store the matching groups
        var matchingGroups: [Group] = []

        // Create a serial dispatch queue
        let serialQueue = DispatchQueue(label: "com.yourapp.fetchGroups")

        // Iterate through the array and fetch groups with matching IDs
        for group in array {
            serialQueue.async {
                let semaphore = DispatchSemaphore(value: 0)
                let targetID = group.groupID
                print("target id" + targetID)

                // Query for the group with the specific document ID
                groupsRef.document(targetID).getDocument { (document, error) in
                    print("jncjdcn")
                    if let error = error {
                        print("Error getting groups: \(error)")
                    } else if let document = document, document.exists {
                        // Get data and assign to Group struct
                        let data = document.data()
                        let group = Group(
                            id: document.documentID,
                            groupName: data?["groupName"] as? String ?? "",
                            dateCreated: data?["dateCreated"] as? Timestamp ?? Timestamp(), // Temporary
                            groupImageURL: data?["groupImageURL"] as? String ?? "",
                            groupSlogan: data?["groupSlogan"] as? String ?? "",
                            groupAdmin: data?["groupAdmin"] as? String ?? "",
                            groupAdminUsername: data?["groupAdminUsername"] as? String ?? "",
                            password: data?["password"] as? String,
                            ticketFormat: data?["ticketFormat"] as? [Int] ?? []
                        )
                        print(" if   " + "\(group)")
                        matchingGroups.append(group)
                    } else {
                        print("sdkjfnsdkjfndskjf")
                    }

                    // Signal the semaphore
                    semaphore.signal()
                }
                // Wait for the semaphore
                semaphore.wait()
            }
        }

        self.canGetHistoricalData = true

        // Notify when all tasks are completed
        serialQueue.async {
            DispatchQueue.main.async {
                // Update the viewModel's userGroups property with all the matching groups
                self.userGroups = matchingGroups
                print("array printed")
                print(matchingGroups)
                completion()
            }
        }
    }

    
    func fetchUserGroups(completion: @escaping () -> Void) {
        
//        let tempArray = self.userTickets.sorted { $0.groupNumber < $1.groupNumber }
        var groupIDs: [String] = ["GlobalDaily"]

        let groupsCollection = db.collection("groups")

        // Create a serial dispatch queue
        let serialQueue = DispatchQueue(label: "com.yourapp.fetchUserGroups")
        
        for (index, groupID) in groupIDs.enumerated() {
            serialQueue.async {
                
                let semaphore = DispatchSemaphore(value: 0)
                print(groupID, "IS GROUP ID")
                
                groupsCollection.document(groupID).getDocument { groupSnapshot, groupError in
                    if let groupError = groupError {
                        print("Error fetching group: \(groupError.localizedDescription)")
                        semaphore.signal()
                        return
                    }
                    
                    guard let groupSnapshot = groupSnapshot, let data = groupSnapshot.data() else {
                        print("Snapshot does not exist or is nil")
                        semaphore.signal()
                        return
                    }

                    if let groupName = data["groupName"] as? String,
                       let dateCreated = Timestamp(date: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 22))!) as? Timestamp,
                       let groupImageURL = data["groupImageURL"] as? String,
                       let groupSlogan = data["groupSlogan"] as? String,
                       let groupAdmin = data["groupAdmin"] as? String,
                       let groupAdminUsername = data["groupAdminUsername"] as? String,
                       let ticketFormat = data["ticketFormat"] as? [Int] {
                    
                        let password = data["password"] as? String
                        
                        let group = Group(id: groupSnapshot.documentID,
                                          groupName: groupName,
                                          dateCreated: dateCreated,
                                          groupImageURL: groupImageURL,
                                          groupSlogan: groupSlogan,
                                          groupAdmin: groupAdmin,
                                          groupAdminUsername: groupAdminUsername,
                                          password: password,
                                          ticketFormat: ticketFormat)
                        
                        self.userGroups.append(group)
                    } else {
                        print("Failed to extract data for groupID: \(groupID)")
                    }
                    //print("joined groups " + "\(self.joinedGroups)")
                    self.weekIndex = 0
                    self.dayIndex = 0
                    self.canGetHistoricalData = true
                    //print("TotalArrayOfDates: ", self.totalArrayOfDates)
                    semaphore.signal()
                }
                
                semaphore.wait()
            }
        }
        
        serialQueue.async {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func populateArrayOfDates(from timestamp: Timestamp) -> [String] {
        var weeks: [String] = []
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC-5")! // Set to Eastern Time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, d, yyyy" // Month, Date, Year
        dateFormatter.timeZone = TimeZone(identifier: "UTC-5")! // Set to Eastern Time

        // Convert Firestore Timestamp to Date and adjust to Eastern Time
        let utcDate = timestamp.dateValue()
        let inputDate = calendar.date(byAdding: .second, value: TimeZone(identifier: "UTC-5")!.secondsFromGMT(), to: utcDate)!

        // Find the most recent Monday (at 12:01 am) in relation to the timestamp
        var currentMonday = inputDate
        while calendar.component(.weekday, from: currentMonday) != 2 { // 2 corresponds to Monday
            currentMonday = calendar.date(byAdding: .day, value: -1, to: currentMonday)!
        }
        currentMonday = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: currentMonday)!

        // Get the current date in Eastern Time
        let currentDateInEasternTime = calendar.date(byAdding: .second, value: TimeZone(identifier: "UTC-5")!.secondsFromGMT(), to: Date())!
        //print("CURRENT DATE UTC+2", currentDateInEasternTime)
        
        // Keep adding Mondays one week later until a Monday in the future is added
        while currentMonday <= currentDateInEasternTime {
            weeks.append(formatDateMMDDYY(from: Timestamp(date: currentMonday)))
            currentMonday = calendar.date(byAdding: .day, value: 7, to: currentMonday)!
        }

        // Remove the future Monday and replace the last valid Monday with "Current Week"
        weeks.removeLast()
        weeks.append("Current")
        weeks.reverse()

        return weeks
    }
    
    func loadPastDailyTicketDates(from timestamp: Timestamp) -> [String] {
        return groupService.populateArrayOfDays(from: timestamp)
    }










    func resetTicketFormat(newTicketFormat: [Int], groupID: String, timeFrame: String, completion: @escaping () -> Void) {
        
        let documentLoc:String = "day"
        let collectionLoc:String = "currentDayTickets"
        let collectionLoc2:String = "currentDayBets"
        
        let db = Firestore.firestore()
        print("NEW TICKET FORMAT", newTicketFormat)
        print("GROUPID", groupID)
        // Step 1: Change the field "ticketFormat" of the document to the new ticketFormat field
        db.collection("groups").document(groupID).updateData([
            "ticketFormat": newTicketFormat
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion()
                return
            }
            
            // Step 2: Collect all of the user ids of the members of the groups
            db.collection("groups").document(groupID).collection("members").getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion()
                    return
                }
                
                let groupUserIds = snapshot?.documents.map { $0.documentID } ?? []
                
                // Use DispatchGroup to wait for all user updates to complete
                let group = DispatchGroup()
                
                for userID in groupUserIds {
                    group.enter()
                    
                    // Step 3: Update ticketFormat for the user's group ticket
                    let ticketsRef = db.collection("users").document(userID).collection("tickets").document(documentLoc).collection(collectionLoc)
                    ticketsRef.whereField("groupID", isEqualTo: groupID).getDocuments { (snapshot, err) in
                        if let err = err {
                            print("Error getting tickets: \(err)")
                        } else {
                            for document in snapshot!.documents {
                                document.reference.updateData([
                                    "ticketFormat": newTicketFormat,
                                    "totalPotentialWon": 0,
                                    "totalWon": 0
                                ]) { err in
                                    if let err = err {
                                        print("Error updating ticket: \(err)")
                                    }
                                }
                            }
                        }

                        // Step 4: Delete all bets for the group
                        let betsRef = db.collection("users").document(userID).collection("bets").document(documentLoc).collection(collectionLoc2)
                        betsRef.whereField("groupID", isEqualTo: groupID).getDocuments { (snapshot, err) in
                            if let err = err {
                                print("Error getting bets: \(err)")
                            } else {
                                for document in snapshot!.documents {
                                    document.reference.delete()
                                }
                            }
                            
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    print("All updates are done!")
                    completion()
                }
            }
        }
    }

}


