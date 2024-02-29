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

class ticketViewModel: ObservableObject {
    
    @Published var totalBetArrays = [[Bet]]()
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
    
    private let groupServe = groupService()
    @Published var userTickets: [Ticket] = [] // Ticket99
    @Published var stats: Stats? = nil
    @Published var profilePicUrl: String = ""
    @Published var userInfo: User? = nil
    
    init() {
        
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
                if timeFrame == "daily" {
                    StaticUserData.shared.dailyRankedTickets = tickets
                } else if timeFrame == "weekly" {
                    StaticUserData.shared.weeklyRankedTickets = tickets
                }
                    //print(tickets)
                    print("test print")
                }

            }
        }

    func fetchFriendTicket(uid: String, with groupID: String, timeFrame: String, completion: @escaping (Result<Ticket, Error>) -> Void) { // Ticket99
        let db = Firestore.firestore()
        
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "currentWeekTickets"
            } else {
                return "currentDayTickets"
            }
        }()
        
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
        
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "pastWeekTickets"
            } else {
                return "pastDayTickets"
            }
        }()
        
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
    
    func fetchPastBets(uid: String, for groupNumber: Int, ticketFormat: [Int], selectedWeek: String, timeFrame: String, completion: @escaping () -> Void) {
        
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "pastWeekBets"
            } else {
                return "pastDayBets"
            }
        }()
        
        print("PAST BETS ARE FETCHED")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Month, Date
        guard let startDate = dateFormatter.date(from: selectedWeek) else {
            return
        }
        print("Start date:", startDate)

        // Calculate the end date, which is one week later
        //let endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        
        var endDate: Date?
        
        
        if timeFrame == "weekly" {
            endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)

        } else if timeFrame == "daily" {
            endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)

        }
        print("End date:", endDate!)
        
        let query = self.db.collection("users").document(uid).collection("bets").document(documentLoc).collection(collectionLoc)
                .whereField("groupNumber", isEqualTo: groupNumber)
                .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
                .whereField("timestamp", isLessThanOrEqualTo: endDate!)
        
        query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("Error getting documents: \(error!)")
                    self.isBetsLoaded = true
                    return
                }
                self.totalBetArrays.removeAll() // Clear previous data
                for (index, parlayMax) in ticketFormat.enumerated() {
                    let betTempArr = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                        return try? queryDocumentSnapshot.data(as: Bet.self)
                    }
                        .filter { $0.betNumber == index+1 }.prefix(parlayMax))
                    self.totalBetArrays.append(betTempArr)
                }
                
                self.calculateTotals(for: groupNumber, ticketFormat: ticketFormat)

                if let error = error {
                    print(error)
                } else {
                    self.currentTicketFormat = ticketFormat
                    self.isBetsLoaded = true
                    self.isTFLoaded = true
                    print("PAST BETS", self.totalBetArrays)
                }

                // Call completion handler
                completion()
            }
        }
    }
    
    func fetchGameInfo() {
        
        
    }
    
    func fetchBets(uid: String, for groupNumber: Int, ticketFormat: [Int], timeFrame: String, completion: @escaping () -> Void) {
        // totalBetArrats
        // availableBetsArray
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "currentWeekBets"
            } else {
                return "currentDayBets"
            }
        }()
        
            let query = self.db.collection("users").document(uid).collection("bets").document(documentLoc).collection(collectionLoc)
                .whereField("groupNumber", isEqualTo: groupNumber)
        query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.totalBetArrays.removeAll() // Clear previous data
                for (index, parlayMax) in ticketFormat.enumerated() {
                    let betTempArr = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                        return try? queryDocumentSnapshot.data(as: Bet.self)
                    }.filter { $0.betNumber == index+1 }.prefix(parlayMax))
                    self.totalBetArrays.append(betTempArr)
                }
 
                self.availableBetsArray.removeAll()
                for (index, parlayMax) in ticketFormat.enumerated() {
                    let betArray = self.totalBetArrays[index]
                    if betArray.filter({ $0.groupNumber == groupNumber }).count >= parlayMax {
                        //print("Appending betNumber:", parlayIndex + 1) // Debug print
                        self.availableBetsArray.append(-1)
                    } else {
                        if betArray.contains(where: { $0.result == .loss }) {
                            self.availableBetsArray.append(-1)
                        } else {
                            self.availableBetsArray.append(index+1)
                        }
                    }
                }
                
                self.calculateTotals(for: groupNumber, ticketFormat: ticketFormat)

                if let error = error {
                    print(error)
                } else {
                    self.currentTicketFormat = ticketFormat
                    self.isBetsLoaded = true
                    self.isTFLoaded = true
                }

                // Call completion handler
                completion()
            }
        }
    }
    
    func deleteBet(bet: Bet, timeFrame: String) {
        
        let documentLoc:String = {
            if timeFrame == "weekly" {
                return "week"
            } else {
                return "day"
            }
        }()
        
        let collectionLoc:String = {
            if timeFrame == "weekly" {
                return "currentWeekTickets"
            } else {
                return "currentDayTickets"
            }
        }()
        
        let collectionLoc2:String = {
            if timeFrame == "weekly" {
                return "currentWeekBets"
            } else {
                return "currentDayBets"
            }
        }()
        
        var whichToInc = -1
        if bet.betType.rawValue == "betHomeSpread" {
            whichToInc = 0
        } else if bet.betType.rawValue == "betAwaySpread" {
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
                                    self.fetchBets(uid: userId, for: bet.groupNumber, ticketFormat: self.currentTicketFormat, timeFrame: timeFrame) {print("Document successfully removed!")
                                        self.groupServe.setPotentialToWin(potential: Int(self.totalPotentialWon), groupNumber: bet.groupNumber, timeFrame: timeFrame, completion: {_ in })
                                    } // fetch the updated list of bets
                //                }
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
                            
                            let data = document.data()
                            if let idd = data["id"] as? String,
                               let commenceTime = data["commenceTime"] as? Timestamp,
                               let totalOver = data["totalOver"] as? Double,
                               let totalUnder = data["totalUnder"] as? Double,
                               let homeTeam = data["homeTeam"] as? String,
                               let awayTeam = data["awayTeam"] as? String,
                               let homeSpread = data["homeSpread"] as? Double,
                               let awaySpread = data["awaySpread"] as? Double,
                               let homeTeamScore = data["homeTeamScore"] as? Int,
                               let awayTeamScore = data["awayTeamScore"] as? Int,
                               let whichSport = data["whichSport"] as? String,
                               let bet_statistics = data["bet_statistics"] as? [Int],
                               let total_plays = data["total_plays"] as? Int,
                               // Extract additional fields here
                               let awayML = data["awayML"] as? Int,
                               let homeML = data["homeML"] as? Int,
                               let awaySpreadODDS = data["awaySpreadODDS"] as? Int,
                               let homeSpreadODDS = data["homeSpreadODDS"] as? Int,
                               let totalOverODDS = data["totalOverODDS"] as? Int,
                               let totalUnderODDS = data["totalUnderODDS"] as? Int
                            {
                                // Ensure completed is correctly extracted or defaulted
                                let completed = data["completed"] as? Bool ?? false

                                // Create the newGame instance with all fields
                                let newGame = Game(id: nil, idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: completed, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays, awayML: awayML, homeML: homeML, awaySpreadODDS: awaySpreadODDS, homeSpreadODDS: homeSpreadODDS, totalOverODDS: totalOverODDS, totalUnderODDS: totalUnderODDS)
                                completion(newGame)
                            }
                            } catch let error {
                                print("Error decoding game document: \(error)")
                                completion(nil)
                        }
                    }
            else {
                print("johnny")
                completion(nil)
            }
        }
    }

    func calculateTotals(for groupNumber: Int, ticketFormat: [Int]) {

        var totalWonLocal: Double = 0.0
        var totalPotentialWonLocal: Double = 0.0

        // Helper function to avoid code duplication
        func calculateForBetArray(_ betArray: [Bet], count: Int) {
            if betArray.count == count {
                let product = betArray.reduce(1.0, { $0 * $1.betOdds })
                let toWin = percentageToTotalWin(percentage: Double(product))
                let potentialWin = Double(toWin.replacingOccurrences(of: "$", with: "")) ?? 0.0

                if betArray.filter({ $0.groupNumber == groupNumber }).allSatisfy({ $0.result == .win }) {
                    totalWonLocal += potentialWin
                }
                
                if betArray.filter({ $0.groupNumber == groupNumber }).contains(where: ({ $0.result == .loss })) {
                    totalWonLocal -= 100
                }

                // check if not all elements in the array are a win
                if !betArray.filter({ $0.groupNumber == groupNumber }).allSatisfy({ $0.result == .win }) &&
                    !betArray.filter({ $0.groupNumber == groupNumber }).contains(where: { $0.result == .loss }) {
                    totalPotentialWonLocal += potentialWin
                }
            }
        }
        for index in 0..<totalBetArrays.count {
            let betArray = totalBetArrays[index]
            calculateForBetArray(betArray, count: ticketFormat[index])
        }

        totalWon = totalWonLocal
        totalPotentialWon = totalPotentialWonLocal
    }
    

    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType) -> Bool {
        for betArray in totalBetArrays {
            for bet in betArray {
                if bet.teamBetOn == team && bet.groupNumber == groupNumber {
                    return false
                }
            }
        }
        return true
    }
    
    func stopListening() {
        listener?.remove()
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
