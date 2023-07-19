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
    
    @Published var totalWon: Double = 0.0
    @Published var totalPotentialWon: Double = 0.0
    @Published var totalWonArray: [Int] = []
    
    @Published var isBetsLoaded = false  // Add this line

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private let groupServe = groupService()
    @Published var userGroups: [Group] = []
    
    init() {
        fetchUserGroups(completion: {})
    }

    func fillTotalsArr() {
        fetchUserGroups {
            for index in 0..<self.userGroups.count {
                self.fetchBets(groupNumber: index, completion: { [self] in
                    self.calculateTotals(for: index)
                    totalWonArray.append(Int(self.totalWon))
                })
            }
        }
    }

    func fetchUserGroups(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        groupServe.fetchUserGroups(userID: userId) { groups, error in
            if let error = error {
                print("Error fetching user groups: \(error.localizedDescription)")
            } else if let groups = groups {
                self.userGroups = groups
                //self.isGroupsLoaded = true  // Set this to true when data is loaded
            }
            completion()
            //print(groups)
            //print(userId)
        }
    }
    
    func fetchBets(groupNumber: Int, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print("userID:" + userId)
        listener = db.collection("users").document(userId).collection("bets")
        .whereField("groupNumber", isEqualTo: groupNumber)
        .addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.betArray1 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 1 }.prefix(1))
            
            self.betArray2 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 2 }.prefix(1))
            
            self.betArray3 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 3 }.prefix(1))
            
            self.betArray4 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 4 }.prefix(1))
            
            self.betArray5 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 5 }.prefix(2))
            
            self.betArray6 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 6 }.prefix(2))
            
            self.betArray7 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 7 }.prefix(3))

            self.betArray8 = Array(documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 8 }.prefix(5))
            
            // only necessary for parlays
            self.updateBetsInResponseToLoss(betArray: &self.betArray5, maxBetsPlaced: 2, groupNumber: groupNumber, betNumber: 5)
            self.updateBetsInResponseToLoss(betArray: &self.betArray6, maxBetsPlaced: 2, groupNumber: groupNumber, betNumber: 6)
            self.updateBetsInResponseToLoss(betArray: &self.betArray7, maxBetsPlaced: 3, groupNumber: groupNumber, betNumber: 7)
            self.updateBetsInResponseToLoss(betArray: &self.betArray8, maxBetsPlaced: 5, groupNumber: groupNumber, betNumber: 8)
            
            self.calculateTotals(for: groupNumber)
            if let error = error {
                print(error)
            } else {
                self.isBetsLoaded = true
            }
            completion()
        }
    }
    
    func availableBets(for groupNumber: Int) -> [Int] {
        var bets = [Int]()
        if betArray1.filter({ $0.groupNumber == groupNumber }).count < 1 { bets.append(1) }
        if betArray2.filter({ $0.groupNumber == groupNumber }).count < 1 { bets.append(2) }
        if betArray3.filter({ $0.groupNumber == groupNumber }).count < 1 { bets.append(3) }
        if betArray4.filter({ $0.groupNumber == groupNumber }).count < 1 { bets.append(4) }
        if betArray5.filter({ $0.groupNumber == groupNumber }).count < 2 { bets.append(5) }
        if betArray6.filter({ $0.groupNumber == groupNumber }).count < 2 { bets.append(6) }
        if betArray7.filter({ $0.groupNumber == groupNumber }).count < 3 { bets.append(7) }
        if betArray8.filter({ $0.groupNumber == groupNumber }).count < 5 { bets.append(8) }
        return bets
    }
    
    func deleteBet(bet: Bet) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("bets").document(bet.id ?? "").delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                
                self.fetchBets(groupNumber: bet.groupNumber) {print("Document successfully removed!")
                    self.groupServe.setPotentialToWin(potential: Int(self.totalPotentialWon), groupNumber: bet.groupNumber, completion: {_ in })
                } // fetch the updated list of bets
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
                let emptyBet = Bet(groupNumber: groupNumber, betNumber: betNumber, betType: .None, betLine: 0, betOdds: 1, result: .forcedLoss, gameID: "null" ) // create as per your requirements
                betArray.append(emptyBet)
            }
        }
    }

    func calculateTotals(for groupNumber: Int) {
        let betArrays1 = [betArray1, betArray2, betArray3, betArray4]
        let betArrays2 = [betArray5, betArray6]
        let betArrays3 = [betArray7]
        let betArrays4 = [betArray8]

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

        for betArray in betArrays1 {
            calculateForBetArray(betArray, count: 1)
        }

        for betArray in betArrays2 {
            calculateForBetArray(betArray, count: 2)
        }

        for betArray in betArrays3 {
            calculateForBetArray(betArray, count: 3)
        }

        for betArray in betArrays4 {
            calculateForBetArray(betArray, count: 5)
        }

        totalWon = totalWonLocal
        totalPotentialWon = totalPotentialWonLocal
    }
    func returnTotal(groupNumber: Int, completion: @escaping (Int) -> Void) {
        fetchBets(groupNumber: groupNumber){
            let result = Int(self.totalWon)
            completion(result)
        }
    }

    func isTeamAvailable(_ team: String,_ groupNumber: Int, _ betType: BetType) -> Bool {
        let allBetArrays = [betArray1, betArray2, betArray3, betArray4, betArray5, betArray6, betArray7, betArray8]

        for betArray in allBetArrays {
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
