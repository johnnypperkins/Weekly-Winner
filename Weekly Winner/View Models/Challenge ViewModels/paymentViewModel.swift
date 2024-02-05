//
//  paymentViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 2/1/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class paymentViewModel: ObservableObject {
    
    @Published var withdrawalHistory: [Withdrawal] = []
    
//    init() {
//        print("INIT FOR WHATEVER REASON")
//    }
    

    func processWithdrawal(userID: String, amount: Double, venmoUsername: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        let withdrawalRef = db.collection("Misc").document("payments").collection("withdrawals").document()

        let batch = db.batch()
        batch.updateData(["poolBucks": FieldValue.increment(-amount)], forDocument: userRef)
        batch.updateData(["poolBucksInWithdrawal": FieldValue.increment(amount)], forDocument: userRef)

        let withdrawalData: [String: Any] = [
            "amount": amount,
            "dateRequested": FieldValue.serverTimestamp(),
            "status": "pending", // or any default status you want to start with
            "uid": userID,
            "venmoUsername": venmoUsername, // Assuming venmoUsername is the correct field name
            "username": StaticUserData.shared.currentUser.username,
            "customID": generateRandomString(length: 20)
        ]

        // 3. Add withdrawal data
        batch.setData(withdrawalData, forDocument: withdrawalRef)

        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error processing withdrawal: \(error.localizedDescription)")
            } else {
                print("Withdrawal processed successfully")
            }
            completion()
        }
    }
    
    

    func fetchWithdrawals(userID: String, completion: @escaping () -> Void) {
        self.withdrawalHistory.removeAll()
        let db = Firestore.firestore()
        db.collection("/Misc/payments/withdrawals")
            .whereField("uid", isEqualTo: userID)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion()
                    return
                }

                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()

                    if let uid: String = data["uid"] as? String,
                       let dateRequested = data["dateRequested"] as? Timestamp,
                       let status = data["status"] as? String,
                       let amount = data["amount"] as? Double,
                       let venmoUsername = data["venmoUsername"] as? String,
                    let customID = data["customID"] as? String{
                        let withdrawal = Withdrawal(uid: uid,
                                                    dateRequested: dateRequested,
                                                    status: status,
                                                    amount: amount,
                                                    venmoUsername: venmoUsername,
                                                    customID: customID)
                        self.withdrawalHistory.append(withdrawal)

                    }
                }
                self.withdrawalHistory.sort(by: { $0.dateRequested.dateValue() > $1.dateRequested.dateValue() })
                print("ALL WITHDRAWALS: \(self.withdrawalHistory)")
                completion()
            }
    }

    

    func fetchUserCoinsAndBucks(userID: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let poolCoins = data?["poolCoins"] as? Double
                let poolBucks = data?["poolBucks"] as? Double
                StaticUserData.shared.currentUser.poolBucks = poolBucks ?? -99
                StaticUserData.shared.currentUser.poolCoins = poolCoins ?? -99
                completion()
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }

    
    func processDeposit() {
        
    }
}
