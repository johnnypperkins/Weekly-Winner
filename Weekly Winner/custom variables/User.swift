//
//  User.swift
//  Merge
//
//  Created by Johnny Perkins on 2/26/23.
//
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Decodable, Encodable {
    @DocumentID var id: String?
    let username: String
    let firstName: String
    let lastName: String
    var profileImageUrl: String
    let email: String
    var keywordsForLookup: [String] {
        [self.firstName.generateStringSequence(), self.lastName.generateStringSequence(), self.username.generateStringSequence()].flatMap { $0 }
    }
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == id
    }
    let dateJoined: Timestamp
    let instagram: String
    let promoCode: String
    let country: String
    let state: String
    let age: Timestamp
    let gender: String
}

extension String { // Lmao what is this johnny
    func generateStringSequence() -> [String] {
        
        guard self.count > 0 else {return [] }
        var sequences: [String] = []
        for i in 1...self.count {
            sequences.append(String(self.prefix(i)))
        }
        return sequences
    }
}


class UserData: ObservableObject {
    @Published var username: String

    init(username: String) {
        self.username = username
    }

    // Singleton instance
    static let shared = UserData(username: "")
}

