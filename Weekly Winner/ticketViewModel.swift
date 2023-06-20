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

    @Published var betArray1 = [Bet]()
    @Published var betArray2 = [Bet]()
    @Published var betArray3 = [Bet]()

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchBets(groupNumber: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("users").document("fY8xGVaMSlZ8xI5HMPeOGBOIarq1").collection("bets")
        .whereField("groupNumber", isEqualTo: groupNumber)
        .order(by: "betNumber")
        .addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }

            self.betArray1 = documents.compactMap { queryDocumentSnapshot -> Bet? in
                do {
                    return try queryDocumentSnapshot.data(as: Bet.self)
                } catch {
                    print("Error decoding data: \(error)")
                    return nil
                }
            }.filter { $0.betNumber == 1 }

            self.betArray2 = documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 2 }

            self.betArray3 = documents.compactMap { queryDocumentSnapshot -> Bet? in
                return try? queryDocumentSnapshot.data(as: Bet.self)
            }.filter { $0.betNumber == 3 }
            print(self.betArray1)
        }
    }

    func stopListening() {
        listener?.remove()
    }
}
