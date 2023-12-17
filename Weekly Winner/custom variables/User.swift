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
    let birthday: Timestamp
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


class StaticUserData: ObservableObject {
    @Published var username: String
    @Published var dailyTicket: Ticket
    @Published var weeklyTicket: Ticket

    init(username: String, dailyTicket: Ticket, weeklyTicket: Ticket) {
        self.username = username
        self.dailyTicket = dailyTicket
        self.weeklyTicket = weeklyTicket
    }

    // Singleton instance
    static let shared = StaticUserData(
        username: "",
        dailyTicket: Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0]),
        weeklyTicket: Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0]))
}

