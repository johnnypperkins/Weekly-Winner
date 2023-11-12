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

    func fetchFriendTicket(uid: String, with groupID: String, completion: @escaping (Result<Ticket, Error>) -> Void) { // Ticket99
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("tickets").document("week").collection("currentWeekTickets")
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
    
    func fetchPastFriendTicket(uid: String, with groupID: String, completion: @escaping (Result<Ticket, Error>) -> Void) { // Ticket99
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("tickets").document("week").collection("pastWeekTickets")
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

    func fetchUserTickets(uid: String, groupNumber: Int, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserTickets(userID: userId) { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                self.userTickets = tickets
                self.currentTicketFormat = tickets[groupNumber].ticketFormat
               
                self.isTFLoaded = true
                //self.isGroupsLoaded = true  // Set this to true when data is loaded
            }
            completion()
            //print(groups)
            //print(userId)
        }
    }//test
    
    func fetchPastBets(uid: String, for groupNumber: Int, ticketFormat: [Int], selectedWeek: String, completion: @escaping () -> Void) {
        
        print("PAST BETS ARE FETCHED")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy" // Month, Date
        guard let startDate = dateFormatter.date(from: selectedWeek) else {
            return
        }
        print("Start date:", startDate)

        // Calculate the end date, which is one week later
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        print("End date:", endDate)
        
            let query = self.db.collection("users").document(uid).collection("bets").document("week").collection("pastWeekBets")
                .whereField("groupNumber", isEqualTo: groupNumber)
                .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
                .whereField("timestamp", isLessThanOrEqualTo: endDate)
        
        query.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    self.isBetsLoaded = true
                    return
                }
                self.totalBetArrays.removeAll() // Clear previous data
                for (index, parlayMax) in ticketFormat.enumerated() {
                    let betTempArr = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                        return try? queryDocumentSnapshot.data(as: Bet.self)
                    }.filter { $0.betNumber == index+1 }.prefix(parlayMax))
                    self.totalBetArrays.append(betTempArr)
                }

//                for index in self.totalBetArrays.indices {
//                    let bet = self.totalBetArrays[index]
//                    if bet.count > 1 {
//                        self.updateBetsInResponseToLoss(betArray: &self.totalBetArrays[index], maxBetsPlaced: self.currentTicketFormat[index], groupNumber: groupNumber, betNumber: index + 1)
//                    }
//                }
                
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
    
    func fetchBets(uid: String, for groupNumber: Int, ticketFormat: [Int], completion: @escaping () -> Void) {
            let query = self.db.collection("users").document(uid).collection("bets").document("week").collection("currentWeekBets")
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
//                for index in self.totalBetArrays.indices {
//                    let bet = self.totalBetArrays[index]
//                    if bet.count > 1 {
//                        self.updateBetsInResponseToLoss(betArray: &self.totalBetArrays[index], maxBetsPlaced: self.currentTicketFormat[index], groupNumber: groupNumber, betNumber: index + 1)
//                        print("BET UPDATED BLAH BLAH")
//                    }
//                }
                
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
    
    func deleteBet(bet: Bet) {
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
                if whichToInc >= 0 && whichToInc < betStatistics.count {
                    betStatistics[whichToInc] -= 1
                    betStatistics[whichToInc+1] -= Int(bet.betLine)
                    ref2.updateData(["bet_statistics": betStatistics]) { err in
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
        
        db.collection("users").document(userId).collection("bets").document("week").collection("currentWeekBets").document(bet.id ?? "").delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                self.fetchUserTickets(uid: userId, groupNumber: bet.groupNumber) {
                    self.fetchBets(uid: userId, for: bet.groupNumber, ticketFormat: self.currentTicketFormat) {print("Document successfully removed!")
                        self.groupServe.setPotentialToWin(potential: Int(self.totalPotentialWon), groupNumber: bet.groupNumber, completion: {_ in })
                    } // fetch the updated list of bets
                }
            }
        }
        
        
    }
    
    // Ok so this function deals with the other bets if there is a loss in a parlay. All .notStarted bets are removed, all empty bets are pushed to null and the betArray is filled
    func updateBetsInResponseToLoss(betArray: inout [Bet], maxBetsPlaced: Int, groupNumber: Int, betNumber: Int) {
        if betArray.contains(where: { $0.result == .loss }) {
            // Create a copy of betArray to avoid modifying array while iterating
            let betArrayCopy = betArray

            for bet in betArrayCopy {
                if bet.result == .notStarted {
                    // Remove from the array
                    if let index = betArray.firstIndex(where: { $0.id == bet.id }) {
                        betArray.remove(at: index)
                    }
                    // Delete from the database
                    deleteBet(bet: bet)
                }
            }

            let remainingSpots = maxBetsPlaced - betArray.count
            print("MAX BETS PLACED", maxBetsPlaced)
            print("BET ARRAY COUNT", betArray.count)
            
            for _ in 0..<remainingSpots {
                let emptyBet = Bet(groupNumber: groupNumber, groupID: "", betNumber: betNumber, betType: .None, betLine: 0, betOdds: 1, result: .forcedLoss, gameID: "null", whichSport: "", timestamp: Timestamp(date: Date()), points_bought: 0) // create as per your requirements
                betArray.append(emptyBet)
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
    
    
    func returnTotal(uid: String, groupNumber: Int, completion: @escaping (Int) -> Void) {
        fetchBets(uid: uid, for: groupNumber, ticketFormat: self.currentTicketFormat){
            let result = Int(self.totalWon)
            completion(result)
        }
    }

    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType) -> Bool {
        for betArray in totalBetArrays {
            for bet in betArray {
                if bet.teamBetOn == team && bet.groupNumber == groupNumber && bet.betType == betType  {
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
