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
            "username": StaticUserData.shared.currentUser.username
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

    
    func processDeposit() {
        
    }
}
