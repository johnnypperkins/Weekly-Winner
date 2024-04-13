//
//  ticketViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/19/23.
//

import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI
import Firebase
import FirebaseFirestore

@MainActor class TicketViewModel: ObservableObject {
        
    @Published var currentUserDailyBets: [Bet] = []
    
    @Published var currentTicketFormat: [Int] = [1,1,1,1,1]
    @Published var totalWon: Double = 0.0
    @Published var totalPotentialWon: Double = 0.0
    @Published var totalWonArray: [Int] = []
    @Published var availableBetsArray: [Int] = []
    
    @Published var isBetsLoaded = false  // Add this line
    @Published var isTFLoaded = false
    @Published var isTicketEnabled = false

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
 
    
    @Published var userTickets: [Ticket] = [] // Ticket99
    @Published var stats: Stats? = nil
    @Published var profilePicUrl: String = ""
    @Published var userInfo: User? = nil
    @Published var isFollow: Bool = false
    @Published var followerCount: Int = 0
    @Published var allDailyTickets: [Ticket] = []
    @Published var allDailyBets: [Bet] = []
    
    private let userService = UserService()
    private let groupServe = GroupService()
    private let betServe = BetService()
    
    
    func isFriend(id: String) async {
        let db = Firestore.firestore()
        
        // Assuming the current user is authenticated
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user is not authenticated.")
            return
        }
        
        // Reference to the potential friend document under the current user's 'friends' collection
        let friendDocRef = db.collection("users").document(currentUserID).collection("friends").document(id)
        
        do {
            let document = try await friendDocRef.getDocument()
            if document.exists {
                self.isFollow = true
            } else {
                self.isFollow = false
            }
        } catch {
            print("Error fetching document: \(error)")
            self.isFollow = false
        }
    }
    
    func follow () {
        userService.follow(uid: Auth.auth().currentUser?.uid ?? "", friendId: userInfo!.id!, username: userInfo!.username, url: userInfo?.profileImageUrl ?? "")
        isFollow = true
        Task{
            await getCountOfStringsInArrayField(user1: StaticUserData.shared.currentUser)
        }
    }
    
    func unfollow () {
        userService.unfollow(uid: Auth.auth().currentUser?.uid ?? "", friendId: userInfo!.id!)
        isFollow = false
        Task{
            await getCountOfStringsInArrayField(user1: StaticUserData.shared.currentUser)
        }
    }
    
    func getCountOfStringsInArrayField(user1: User) async{
        let count = 0
        // Assuming you have a reference to your Firebase Firestore database
        let db = Firestore.firestore()

        // Replace "yourCollection" with the name of your collection
        // and "yourDocumentID" with the ID of the document you want to fetch
        let docRef = db.collection("users").document(user1.id!)

        // Fetch the document
        Task{
            await docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let array = document.get("friends") as? [String] {
                        // Access the array field and get the count
                        self.followerCount = array.count
                        print("Count of strings in array: \(count)")
                    } else {
                        print("Array field not found or not of type [String]")
                    }
                } else {
                    print("Document does not exist")
                }
            }
                
            }
        }
    
    func fetchUserProfilePic(uid: String, completion: @escaping () -> Void) {
        //let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error checking if blocked: \(error.localizedDescription)")
                completion()
            } else {
                let profileImageUrl = documentSnapshot?.data()?["profileImageUrl"] as? String
                self.profilePicUrl = profileImageUrl ?? ""
                completion()
            }
        }
    }
    
    
    
    func fetchUserInformation(uid: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion()
                return
            }
            
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    self.userInfo = userData
                    completion()
                } catch {
                    print("Error decoding user: \(error)")
                    completion()
                }
            } else {
                print("Document does not exist")
                completion()
            }
        }
    }
    
    
    func fetchStats(uid: String, completion: @escaping () -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("Misc")
            .document("stats")
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion()
                    return
                }

                guard let snapshot = snapshot else {
                    print("Snapshot is nil.")
                    completion()
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
                    self.stats = statistics
                    completion()
                } else {
                    print("Document does not exist.")
                    completion()
                }
            }
    }
    
    func fetchCurrentRankedTickets(groupID: String, timeFrame: String, completion: @escaping () -> Void){
        groupServe.getCurrentRankedTickets(groupID: groupID, timeFrame: timeFrame) { [weak self] (tickets, totalPlayers, error) in
            if let error = error {
                print(error)
            } else if let tickets = tickets {
                StaticUserData.shared.dailyRankedTickets = tickets
            }
        }
    }

    func fetchFriendTicket(uid: String, with groupID: String, timeFrame: String, completion: @escaping (Result<Ticket, Error>) -> Void) { // Ticket99
        let db = Firestore.firestore()
        
        let documentLoc = "day"
        let collectionLoc = "currentDayTickets"
        
        db.collection("users").document(uid).collection("tickets").document(documentLoc).collection(collectionLoc)
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    let ticket = Ticket(username: "error", uid: "", groupID: "", groupNumber: 0, dateCreated: Timestamp(date: Date.now), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [])
                    self.userTickets.append(ticket)
                    completion(.failure(err))
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let ticket = try document.data(as: Ticket.self) // Ticket99
                            self.userTickets.append(ticket)
                            completion(.success(ticket))
                        } catch {
                            print("Error decoding group: \(error)")
                            let ticket = Ticket(username: "error", uid: "", groupID: "", groupNumber: 0, dateCreated: Timestamp(date: Date.now), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [])
                            self.userTickets.append(ticket)
                            completion(.failure(error))
                        }
                    }
                }
            }
    }
    
    func fetchPastFriendTicket(uid: String, with groupID: String, timeFrame: String, completion: @escaping (Result<Ticket, Error>) -> Void) { // Ticket99
        let db = Firestore.firestore()
        
        let documentLoc = "day"
        
        let collectionLoc = "pastDayTickets"
        
        db.collection("users").document(uid).collection("tickets").document(documentLoc).collection(collectionLoc)
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(.failure(err))
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let ticket = try document.data(as: Ticket.self) // Ticket99
                            self.userTickets.append(ticket)
                            completion(.success(ticket))
                        } catch {
                            print("Error decoding group: \(error)")
                            completion(.failure(error))
                        }
                    }
                }
            }
    }

    func fetchUserTickets(timeFrame: String, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserTickets(userID: userId, timeFrame: timeFrame) { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                self.userTickets = tickets
                self.currentTicketFormat = tickets[0].ticketFormat
                if timeFrame == "weekly" {
                    StaticUserData.shared.weeklyTicket = tickets[0]
                } else if timeFrame == "daily" {
                    StaticUserData.shared.dailyTicket = tickets[0]

                }
                self.isTFLoaded = true
                //self.isGroupsLoaded = true  // Set this to true when data is loaded
            }
            completion()

        }
    }
    
    func fetchBets(uid: String, currentWeek: Bool, selectedWeek: String, completion: @escaping () -> Void) {
        betServe.fetchBets(uid: uid, currentWeek: currentWeek, selectedWeek: selectedWeek) { bets, error in
            if let error = error {
                print(error)
                completion()
            } else {
                self.currentTicketFormat = [0,0,0,0]
                self.isBetsLoaded = true
                self.isTFLoaded = true
                self.currentUserDailyBets = bets
                completion()
            }
        }
    }
    
    func deleteBet(bet: Bet, timeFrame: String) {
        
        let documentLoc = "day"
        let collectionLoc:String = "currentDayTickets"
        let collectionLoc2 = "currentDayBets"
        
        var whichToInc = -1
        if bet.betType.rawValue == "betHomeSpread" || bet.betType.rawValue == "betHomeML" {
            whichToInc = 0
        } else if bet.betType.rawValue == "betAwaySpread" || bet.betType.rawValue == "betAwayML" {
            whichToInc = 2
        } else if bet.betType.rawValue == "over" {
            whichToInc = 4
        } else if bet.betType.rawValue == "under" {
            whichToInc = 6
        }
        
        let ref2 = db.collection("Book").document(bet.whichSport).collection("games").document(bet.gameID)

        ref2.getDocument { (document, error) in
            if let document = document, document.exists {
                var betStatistics = document.get("bet_statistics") as? [Int] ?? []
                var total_plays = document.get("total_plays") as? Int ?? 0
                if whichToInc >= 0 && whichToInc < betStatistics.count {
                    betStatistics[whichToInc] -= 1
                    betStatistics[whichToInc+1] -= Int(bet.betLine)
                    total_plays -= 1
                    ref2.updateData([
                        "bet_statistics": betStatistics,
                        "total_plays": total_plays
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            } else if let err = error {
                print("Error getting document: \(err)")
            }
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("bets").document(documentLoc).collection(collectionLoc2).document(bet.id ?? "").delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                self.fetchUserTickets(timeFrame: timeFrame) {
                    self.fetchBets(uid: userId, currentWeek: true, selectedWeek: "n/a") {
                        print("Document successfully removed!")
                        self.groupServe.setPotentialToWin(potential: Int(returnPotentialFromAllStraights(bets: self.currentUserDailyBets)), groupNumber: bet.groupNumber, timeFrame: timeFrame, completion: {_ in })
                    }
                }
            }
            
        }
        
    }
    
    func fetchGameDocument(byID documentID: String, completion: @escaping (Game?) -> Void) {
        let db = Firestore.firestore()
        
        db.collectionGroup("games").whereField("id", isEqualTo: documentID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting game document: \(error)")
                return
            }
            if let document = querySnapshot?.documents.first {
                do {
                    let game = try document.data(as: Game.self)
                    completion(game)
                    
                } catch let error {
                    completion(nil)
                }
            } else {
                print("Error decoding game document: \(error)")
                completion(nil)
            }
        }
    }


    
    func fetchUserBetsForStats(uid: String, completion: @escaping () -> Void) {
        self.allDailyBets.removeAll()
        Firestore.firestore().collection("users").document(uid).collection("bets")
            .document("day").collection("currentDayBets")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion()
                    return
                }
                //var localUserBets: [Bet] = []
                let documents = querySnapshot?.documents ?? []
                
                for doc in documents {
                    do {
                        if let bet = try doc.data(as: Bet?.self) {
                            self.allDailyBets.append(bet)
                        }
                    } catch let error {
                        print("Error decoding bet1: \(error.localizedDescription), UID: \(uid)")
                        
                    }
                }
                
                
            }
        
        Firestore.firestore().collection("users").document(uid).collection("bets")
            .document("day").collection("pastDayBets")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion()
                    return
                }
                var localUserBets: [Bet] = []
                let documents = querySnapshot?.documents ?? []
                
                for doc in documents {
                    do {
                        if let bet = try doc.data(as: Bet?.self) {
                            self.allDailyBets.append(bet)
                        }
                    } catch let error {
                        print("Error decoding bet2: \(error.localizedDescription), UID: \(uid)")
                    }
                }
                
                
            }
        completion()
        
    }
    
    func fetchUserticketsForStats(uid: String, completion: @escaping () -> Void) {
        self.allDailyTickets.removeAll()

        Firestore.firestore().collection("users").document(uid).collection("tickets")
            .document("day").collection("currentDayTickets")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion()
                    return
                }
                //var localUserBets: [Bet] = []
                let documents = querySnapshot?.documents ?? []
                
                for doc in documents {
                    do {
                        if let ticket = try doc.data(as: Ticket?.self) {
                            self.allDailyTickets.append(ticket)
                        }
                    } catch let error {
                        print("Error decoding bet3: \(error.localizedDescription)")
                    }
                }
                
                
            }
        
        Firestore.firestore().collection("users").document(uid).collection("tickets")
            .document("day").collection("pastDayTickets")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    completion()
                    return
                }
                var localUserBets: [Bet] = []
                let documents = querySnapshot?.documents ?? []
                
                for doc in documents {
                    do {
                        if let ticket = try doc.data(as: Ticket?.self) {
                            self.allDailyTickets.append(ticket)
                        }
                    } catch let error {
                        print("Error decoding bet4: \(error.localizedDescription)")
                    }
                }
                
                
            }
        completion()
        
    }
    
    func stopListening() {
        listener?.remove()
    }
}




extension TicketViewModel {
    

    
    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType) -> Bool {
        
        for bet in currentUserDailyBets {
            if bet.teamBetOn == team && bet.groupNumber == groupNumber {
                return false
            }
        }
        
        return true
    }
    
}

func parlayTitle(ticketFormat: [Int], index: Int) -> String {
    guard index < ticketFormat.count else {
        return "..." // Handle the case where index is out of bounds
    }
    
    let valueAtIndex = ticketFormat[index]
    let legTitle: String
    
    switch valueAtIndex {
    case 1:
        legTitle = "Straight"
    case 2...5:
        legTitle = "\(valueAtIndex) Leg"
    default:
        return "Invalid value" // Handle other cases if needed
    }
    
    // Find the occurrence of the same value
    let occurrence = ticketFormat[..<index].filter { $0 == valueAtIndex }.count + 1

    return "\(legTitle) \(occurrence)"
}
