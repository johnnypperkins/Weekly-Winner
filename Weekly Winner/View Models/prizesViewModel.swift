//
//  prizesViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/20/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class prizesViewModel: ObservableObject {
    @Published var prizes:[String] = []
    @Published var canViewPrizes = false
    
    init() {
        self.getPrizes() {
            self.canViewPrizes = true
        }
    }
    
    func getPrizes( completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("Misc").document("globalPrizes")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let firstPrize = data?["1st"] as? String,
                   let secondPrize = data?["2nd"] as? String,
                   let thirdPrize = data?["3rd"] as? String,
                   let fourthPrize = data?["4th"] as? String,
                   let fifthPrize = data?["5th"] as? String {
                    print("1st prize is: \(firstPrize)")
                    print("2nd prize is: \(secondPrize)")
                    print("3rd prize is: \(thirdPrize)")
                    print("4th prize is: \(fourthPrize)")
                    print("5th prize is: \(fifthPrize)")
                    self.prizes = [firstPrize, secondPrize, thirdPrize, fourthPrize, fifthPrize]
                    completion()
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
