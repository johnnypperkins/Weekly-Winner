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
        [/*self.firstName.generateStringSequence(), self.lastName.generateStringSequence(), */self.username.lowercased().generateStringSequence()].flatMap { $0 }
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
    var poolCoins: Double
    var poolBucks: Double
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
    @Published var currentUser: User
    @Published var dailyTicket: Ticket
    @Published var weeklyTicket: Ticket
    @Published var dailyRankedTickets: [Ticket]
    @Published var weeklyRankedTickets: [Ticket]

    init(username: String, currentUser: User, dailyTicket: Ticket, weeklyTicket: Ticket, dailyRankedTickets: [Ticket], weeklyRankedTickets: [Ticket]) {
        self.username = username
        self.currentUser = currentUser
        self.dailyTicket = dailyTicket
        self.weeklyTicket = weeklyTicket
        self.dailyRankedTickets = dailyRankedTickets
        self.weeklyRankedTickets = weeklyRankedTickets
    }

    // Singleton instance
    static var shared = StaticUserData(
        username: "",
        currentUser: User(id: "", username: "", firstName: "", lastName: "", profileImageUrl: "", email: "", dateJoined: Timestamp(date:Date()), instagram: "", promoCode: "", country: "", state: "", birthday: Timestamp(date:Date()), gender: "", poolCoins: 0.0, poolBucks: 0.0),
        dailyTicket: Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0]),
        weeklyTicket: Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0]),
        dailyRankedTickets: [Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0])],
        weeklyRankedTickets: [Ticket(id: "", username: "", uid: "", groupID: "", groupNumber: -99, dateCreated: Timestamp(date:Date()), totalWon: 0, totalPotentialWon: 0, groupName: "", rank: "", isEnabled: false, groupAdmin: "", ticketFormat: [0])])
    
}
