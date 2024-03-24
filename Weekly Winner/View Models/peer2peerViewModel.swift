//
//  peer2peerViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 3/8/24.
//

import Foundation
import Firebase

struct Friend: Identifiable, Equatable {
    let id: String
    let username: String
    let profileImageURL: String
}

class peer2peerViewModel: ObservableObject {
    let db = Firestore.firestore()
    
    @Published var selectedBet: Bet? = nil
    @Published var customID: String? = nil
    @Published var senderDirectTicket: DirectChallengeTicket? = nil
    @Published var queriedUsers: [User] = []
    @Published var friends: [Friend] = []
    
    @Published var usernameSearch: String = ""
    
    var searchTask: DispatchWorkItem?

    
    
    init() {
        //self.setCustomID()
        fetchFriends()
    }
    
    
    
    func fetchFriends() {
            let db = Firestore.firestore()
            
        db.collection("users").document(StaticUserData.shared.currentUser.id!).collection("friends").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting friends: \(error)")
                } else {
                    // Temporary array to hold fetched friends
                    var fetchedFriends: [Friend] = []
                    
                    // Extracting friend data
                    for document in snapshot?.documents ?? [] {
                        let username = document.data()["username"] as? String ?? "Unknown"
                        let profileImageURL = document.data()["profileImageURL"] as? String ?? ""
                        fetchedFriends.append(Friend(id: document.documentID, username: username, profileImageURL: profileImageURL))
                    }
                    
                    // Sorting the friends array alphabetically by username
                    self.friends = fetchedFriends.sorted { $0.username < $1.username }
                }
            }
        }
    

    
//    func setCustomID() {
//        self.customID = generateRandomString(length: 20)
//    }
    
    func setSelectedBet(bet: Bet) {
        self.selectedBet = bet
    }
    
    func setSenderDirectTicket(senderTicket: DirectChallengeTicket) {
        self.senderDirectTicket = senderTicket
    }
    func fetchUser(from keyword: String) {
        // Calculate the end value for the query
        if keyword != "" {
            
            db.collection("users")
                .whereField("username", isEqualTo: keyword)
                .limit(to: 1)
                .getDocuments { querySnapshot, error in
                    guard let documents = querySnapshot?.documents, error == nil else { return }
                    self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                        try? queryDocumentSnapshot.data(as: User.self)
                    }
                }
        }
    }
    
    func delayedFetchUser(from keyword: String) {
        // Cancel the previous task if it exists
        searchTask?.cancel()

        // Create a new task
        let task = DispatchWorkItem { [weak self] in
            self?.fetchUser(from: keyword)
        }

        // Save the new task
        searchTask = task

        // Execute the task after 300 milliseconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: task)
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
    
    
    func sendChallenge(senderWagerAmount: Int, game: Game, sendingToPublic: Bool, sendingToFriends: Bool, completion: @escaping () -> Void) {
        let customID = generateRandomString(length: 20)
        
        // 1. Send bets to own user
        self.deductCurrencyFromUsers(challengeTicket: self.senderDirectTicket!, senderWagerAmount: Double(senderWagerAmount)) {
                
            let senderBetPath = self.db.collection("users").document(self.senderDirectTicket!.senderID).collection("challenges").document("bets").collection("currentWeekBets")
                
                var betData: [String: Any] = [
                    "groupNumber": self.selectedBet?.groupNumber ?? 0,
                    "betNumber": self.selectedBet?.betNumber ?? 0,
                    "betType": self.selectedBet?.betType.rawValue ?? "",
                    "betLine": self.selectedBet?.betLine ?? 0,
                    "betOdds": MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: self.selectedBet?.betType ?? .None)), // NEEDS TO BE ADJUSTED MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))
                    "result": self.selectedBet?.result.rawValue ?? "",
                    "gameID": self.selectedBet?.gameID ?? "",
                    "groupID": customID,
                    "whichSport": self.selectedBet?.whichSport ?? "",
                    "timestamp": self.selectedBet?.timestamp ?? "",
                    "teamBetOn": self.selectedBet?.teamBetOn ?? "", // NEEDS TO BE ADJUSTED
                    "points_bought": self.selectedBet?.points_bought ?? "",
                    "timeFrame": ""
                ]
                
                
                senderBetPath.addDocument(data: betData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    }
                }
                    

                // 2. Send challenge ticket to own user
                    
                    // YOUR TICKET
                    let senderTicketData: [String: Any] = [
                        "customID": customID,
                        
                        "senderUsername": self.senderDirectTicket?.senderUsername,
                        "senderID": self.senderDirectTicket?.senderID,
                        "senderOdds": self.senderDirectTicket?.senderOdds,
                        "senderBetType": self.senderDirectTicket?.senderBetType.rawValue, // Assuming BetType is an enum and you want to store its raw value
                        
                        "senderBetLine": self.senderDirectTicket?.senderBetLine,
                        "senderTeamName": self.senderDirectTicket?.senderTeamName,
                        
                        
                        "senderWagerAmount": senderWagerAmount,
                        
                        "receiverUsername": sendingToPublic ? "" : self.senderDirectTicket?.receiverUsername,
                        "receiverID": sendingToPublic ? "" : self.senderDirectTicket?.receiverID,
                        "receiverOdds": self.senderDirectTicket?.receiverOdds,
                        "receiverBetType": self.senderDirectTicket?.receiverBetType.rawValue, // Assuming BetType is an enum and you want to store its raw value
                        "receiverBetLine": self.senderDirectTicket?.receiverBetLine,
                        "receiverTeamName": self.senderDirectTicket?.receiverTeamName,
                        
                        "receiverWagerAmount": returnOpponentWagerAmount(
                            wagerAmount: Double(senderWagerAmount),
                            odds1: self.senderDirectTicket!.senderOdds,
                            odds2: self.senderDirectTicket!.receiverOdds,
                            betType: self.senderDirectTicket!.receiverBetType, 
                            game: game),
                        
                        "dateCreated": self.senderDirectTicket?.dateCreated, // Adjust based on how you're planning to fix this later
                        "currencyChosen": "poolBucks", // will adjust in future
                        "status": sendingToPublic ? (sendingToFriends ? "pendingFriendsAcceptance" : "pendingPublicAcceptance") : self.senderDirectTicket?.status,
                        "gameIDs": self.senderDirectTicket?.gameIDs,
                        "gameCommenceTime": self.senderDirectTicket?.gameCommenceTime,
                        "challengeType" : self.senderDirectTicket?.challengeType
                    ]


                let challengePath = self.db.collection("users").document(self.senderDirectTicket!.senderID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(customID)
                challengePath.setData(senderTicketData) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        completion()
                    }
                }
            
                if !sendingToPublic {
                    let challengePath2 = self.db.collection("users").document(self.senderDirectTicket!.receiverID).collection("challenges").document("tickets").collection("currentChallengeTickets").document(customID)

                    challengePath2.setData(senderTicketData) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            completion()
                        }
                    }
                }
            
            }
        failure: { errorMessage in
            print("Currency deduction failed: \(errorMessage)")
        }
    }
    
    func deductCurrencyFromUsers(challengeTicket: DirectChallengeTicket, senderWagerAmount: Double, completion: @escaping () -> Void, failure: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        

        let challengerRef = db.collection("users").document(challengeTicket.senderID)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                // Read phase
                let challengerDoc = try transaction.getDocument(challengerRef)

                guard let challengerCurrency = challengerDoc.data()?[challengeTicket.currencyChosen] as? Double,
                      
                      challengerCurrency >= senderWagerAmount
                      else {
                    let errorMessage = "Insufficient funds"
                    errorPointer?.pointee = NSError(domain: "AppErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    return nil
                }

                // Write phase
                let newChallengerCurrency = challengerCurrency - senderWagerAmount
                if challengeTicket.currencyChosen == "poolCoins" {
                    StaticUserData.shared.currentUser.poolCoins = newChallengerCurrency
                }
                else {
                    StaticUserData.shared.currentUser.poolBucks = newChallengerCurrency
                }

                transaction.updateData([challengeTicket.currencyChosen: newChallengerCurrency], forDocument: challengerRef)

                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        }, completion: { _, error in
            if let error = error {
                failure("Currency deduction failed: \(error.localizedDescription)")
            } else {
                completion()
            }
        })
    }
}
