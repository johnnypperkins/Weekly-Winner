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

class ticketViewModel: ObservableObject {
    
    @Published var betArray1 = [Bet]() // Straight #1
    @Published var betArray2 = [Bet]() // Straight #2
    @Published var betArray3 = [Bet]() // Straight #3
    @Published var betArray4 = [Bet]() // Straight #4
    @Published var betArray5 = [Bet]() // 2 Leg #1
    @Published var betArray6 = [Bet]() // 2 Leg #2
    @Published var betArray7 = [Bet]() // 3 Leg #1
    @Published var betArray8 = [Bet]() // 5 Leg
    
    @Published var totalBetArrays = [[Bet]]()
    @Published var currentTicketFormat: [Int] = [1,1,1,1,1]
    
    @Published var totalWon: Double = 0.0
    @Published var totalPotentialWon: Double = 0.0
    @Published var totalWonArray: [Int] = []
    @Published var availableBetsArray: [Int] = []
    
    @Published var isBetsLoaded = false  // Add this line
    @Published var isTicketEnabled = false

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private let groupServe = groupService()
    @Published var userTickets: [Ticket] = [] // Ticket99
    


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

    func fetchUserTickets(uid: String, groupNumber: Int, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserTickets(userID: userId) { tickets, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let tickets = tickets {
                self.userTickets = tickets
                self.currentTicketFormat = tickets[groupNumber].ticketFormat
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
        dateFormatter.dateFormat = "MMMM, d, yyyy" // Month, Date
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

                for index in self.totalBetArrays.indices {
                    let bet = self.totalBetArrays[index]
                    if bet.count > 1 {
                        self.updateBetsInResponseToLoss(betArray: &self.totalBetArrays[index], maxBetsPlaced: self.currentTicketFormat[index], groupNumber: groupNumber, betNumber: index + 1)
                    }
                }
                
                self.calculateTotals(for: groupNumber, ticketFormat: ticketFormat)

                if let error = error {
                    print(error)
                } else {
                    self.currentTicketFormat = ticketFormat
                    self.isBetsLoaded = true
                    print("PAST BETS", self.totalBetArrays)
                }

                // Call completion handler
                completion()
            }
        }
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
                for index in self.totalBetArrays.indices {
                    let bet = self.totalBetArrays[index]
                    if bet.count > 1 {
                        self.updateBetsInResponseToLoss(betArray: &self.totalBetArrays[index], maxBetsPlaced: self.currentTicketFormat[index], groupNumber: groupNumber, betNumber: index + 1)
                    }
                }
                
                self.calculateTotals(for: groupNumber, ticketFormat: ticketFormat)

                if let error = error {
                    print(error)
                } else {
                    self.currentTicketFormat = ticketFormat
                    self.isBetsLoaded = true
                }

                // Call completion handler
                completion()
            }
        }
    }
    
    func deleteBet(bet: Bet) {
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
            for _ in 0..<remainingSpots {
                let emptyBet = Bet(groupNumber: groupNumber, groupID: "", betNumber: betNumber, betType: .None, betLine: 0, betOdds: 1, result: .forcedLoss, gameID: "null", timestamp: Timestamp(date: Date()) ) // create as per your requirements
                betArray.append(emptyBet)
            }
        }
    }

    func calculateTotals(for groupNumber: Int, ticketFormat: [Int]) {
//        let betArrays1 = [betArray1, betArray2, betArray3, betArray4]
//        let betArrays2 = [betArray5, betArray6]
//        let betArrays3 = [betArray7]
//        let betArrays4 = [betArray8]

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

//
//        for betArray in betArrays1 {
//            calculateForBetArray(betArray, count: 1)
//        }
//
//        for betArray in betArrays2 {
//            calculateForBetArray(betArray, count: 2)
//        }
//
//        for betArray in betArrays3 {
//            calculateForBetArray(betArray, count: 3)
//        }
//
//        for betArray in betArrays4 {
//            calculateForBetArray(betArray, count: 5)
//        }

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
        return "Index out of range" // Handle the case where index is out of bounds
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
