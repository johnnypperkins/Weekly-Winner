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

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchBets(groupNumber: Int) {
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
        }
    }

    func stopListening() {
        listener?.remove()
    }
}
