
import Foundation
import Firebase

class ReferralViewModel: ObservableObject {
    @Published var numReferrals = 0
    @Published var referredUsers = [User]()
    
    func fetchUsersWithPromoCode(completion: @escaping (Error?) -> Void) {
        let promoCode = StaticUserData.shared.currentUser.username
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("promoCode", isEqualTo: promoCode)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                var users = [User]()
                for document in snapshot?.documents ?? [] {
                    do {
                        let user = try document.data(as: User.self)
                        users.append(user)
                    } catch let error {
                        print("Error decoding user: \(error)")
                    }
                }
                self.referredUsers = users
                completion(nil)
            }
    }
    
}
