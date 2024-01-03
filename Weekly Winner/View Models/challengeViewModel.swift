//
//  challengeViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

import Foundation
import Firebase

class challengeViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var queriedUsers: [User] = []
    @Published var opponentUsernameExists: Bool = false
    @Published var service = BetService()
    @Published var allGames: [Game] = []

    init() {
        self.fetchAllGames() {}
    }
    
//    func createGroup(groupImageURL: UIImage?, groupAdminUsername: String, groupName: String, groupSlogan: String, password: String, ticketFormat: [Int]) {
//        
//        if groupImageURL != nil {
//            imageUploader.uploadImage(use: "group", image: groupImageURL!) { URL in
//                
//                self.groupImageURLString = URL
//                self.service.createGroup(groupAdminUsername: groupAdminUsername, groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: ticketFormat, groupUrl: self.groupImageURLString) { result in
//                    switch result {
//                    case .success(let documentID):
//                        print("Document added with ID: \(documentID)")
//                    case .failure(let error):
//                        print("Error adding document: \(error)")
//                    }
//                }
//            }
//        }
//        else {
//            self.service.createGroup(groupAdminUsername: groupAdminUsername, groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: ticketFormat, groupUrl: "") { result in
//                switch result {
//                case .success(let documentID):
//                    print("Document added with ID: \(documentID)")
//                case .failure(let error):
//                    print("Error adding document: \(error)")
//                }
//            }
//        }
//    }
    
    
    func fetchUser(from keyword: String) {
        db.collection("users").whereField("keywordsForLookup", arrayContains: keyword).limit(to: 5).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedUsers = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: User.self)
            }
        }
    }
    
    func checkUsernameAvailable(username: String, completion: @escaping (User?, Bool) -> Void) {
        let usersCollection = db.collection("users")
        usersCollection.whereField("username", isEqualTo: username.lowercased()).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, false) // Return nil and false in case of error
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                // User exists
                // Manual mapping to create a User object
                if let data = documents.first?.data() {
                    let user = User(
                        id: data["id"] as? String,
                        username: data["username"] as? String ?? "",
                        firstName: data["firstName"] as? String ?? "",
                        lastName: data["lastName"] as? String ?? "",
                        profileImageUrl: data["profileImageUrl"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        dateJoined: data["dateJoined"] as? Timestamp ?? Timestamp(),
                        instagram: data["instagram"] as? String ?? "",
                        promoCode: data["promoCode"] as? String ?? "",
                        country: data["country"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        birthday: data["birthday"] as? Timestamp ?? Timestamp(),
                        gender: data["gender"] as? String ?? ""
                    )
                    completion(user, true)
                } else {
                    completion(nil, true)
                }
            } else {
                // No user found
                completion(nil, false)
            }
        }
    }
    
    
    
    func fetchAllGames(completion: @escaping () -> Void) {
        self.allGames.removeAll()
        var tempGames: [Game] = []
        let sportsArr = ["NFL", "NCAAF", "NBA", "NCAAB"]
        let group = DispatchGroup()

        for sport in sportsArr {
            group.enter() // Enter the group for each sport

            Firestore.firestore().collection("Book").document(sport).collection("games")
                .order(by: "commenceTime").getDocuments { querySnapshot, error in

                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        group.leave() // Leave the group in case of an error
                        return
                    }

                    var games: [Game] = []

                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let idd = data["id"] as? String,
                           let commenceTime = data["commenceTime"] as? Timestamp,
                           let totalOver = data["totalOver"] as? Double,
                           let totalUnder = data["totalUnder"] as? Double,
                           let homeTeam = data["homeTeam"] as? String,
                           let awayTeam = data["awayTeam"] as? String,
                           let homeSpread = data["homeSpread"] as? Double,
                           let awaySpread = data["awaySpread"] as? Double,
                           let homeTeamScore = data["homeTeamScore"] as? Int,
                           let awayTeamScore = data["awayTeamScore"] as? Int,
                           let whichSport = data["whichSport"] as? String? ?? "",
                           let bet_statistics = data["bet_statistics"] as? [Int],
                           let total_plays = data["total_plays"] as? Int {
                            let newGame = Game(idd: idd, awaySpread: awaySpread, awayTeam: awayTeam, homeSpread: homeSpread, homeTeam: homeTeam, commenceTime: commenceTime, completed: false, totalOver: totalOver, totalUnder: totalUnder, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore, whichSport: whichSport, bet_statistics: bet_statistics, total_plays: total_plays)
                            games.append(newGame)
                        }
                    }

                    tempGames.append(contentsOf: games)
                    group.leave() // Leave the group when done processing this sport
                }
        }

        group.notify(queue: .main) {
            self.allGames = tempGames.sorted { $0.commenceTime.dateValue() < $1.commenceTime.dateValue() }
            completion() // Call the completion handler once all sports are processed
        }
    }



    
}
