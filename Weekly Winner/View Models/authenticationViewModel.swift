//
//  authenticationViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/8/23.
//

import Firebase
import FirebaseFirestore



enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}


@MainActor
class authenticationViewModel: ObservableObject {
    
    private let service = userService()
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var userSession : FirebaseAuth.User? = nil
    @Published var currUser: User?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var Repassword: String = ""
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var authResult: AuthDataResult? = nil
    @Published var errorMessage: String? = ""
    @Published var instagram: String = ""
    @Published var promoCode: String = ""
    let currentVersion: String = "1.12"
    @Published var updateURL: String = ""

    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser() {}
        
    }
    
    func forceUpdate(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let updatesDocument = db.collection("Misc").document("updates")
        
        updatesDocument.getDocument { document, error in
                if let error = error {
                    print("Error fetching document: \(error)")
                    completion()
                    return
                }
                
                guard let document = document, document.exists,
                      let version = document["version"] as? String,
                      let updateURL2 = document["updateURL"] as? String else {
                    print("Document not found or fields missing")
                    completion()
                    return
                }
            print("DATABASE VERSION", version)
            print("IOS VERSION", self.currentVersion)
                
            if self.currentVersion != version {
                    self.updateURL = updateURL2
                    completion()
                } else {
                    completion()
                }
            }
    }
    
    func showMainScreen() {
        userSession = authResult!.user
        print("helllllllll\(userSession)")
        
    }
    
    func uploadSupplementaryData(country: String, age: Int, state: String, gender: String) {
        guard let uid = Auth.auth().currentUser else {return }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["country": country]) { _ in
            
        }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["age": age]) { _ in
            
        }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["gender": gender]) { _ in
            
        }
        if state != "Choose here" {
            Firestore.firestore().collection("users").document(uid.uid).updateData(["state": state]) { _ in
            
        }
    }
        
    }
    
    
    func signUp() async {
            authenticationState = .authenticating
            
            do {
                authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                //userSession = authResult!.user // added - Reid
                let user = authResult!.user
                
                let newUser = User(username: username, firstName: firstName, lastName: lastName, profileImageUrl: "", email: email, dateJoined: Timestamp(date: Date()), instagram: instagram, promoCode: promoCode, country: "",state: "", age: -99, gender: "")
                await uploadUser(newUser)
                
                authenticationState = .authenticated
                joinGlobal { error in
                 print(error)
                }
            } catch let error {
                // Handle signup error
                errorMessage = error.localizedDescription
                print("Signup error: \(error.localizedDescription)")
                authenticationState = .unauthenticated
            }
        }
    
    func signIn() {
            authenticationState = .authenticating
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle sign-in error
                    print("Sign-in error: \(error.localizedDescription)")
                    self.authenticationState = .unauthenticated
                } else {
                    // Sign-in successful
                    self.userSession = authResult!.user  // Set placeholder user session

                    self.fetchUser() { } // sets user to user instead of nil

                    self.authenticationState = .authenticated
                    print("sign in successful")

                }
            }
        }
    
    func forgotPassButton_Tapped(email: String, completion: @escaping () -> Void) {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                self.errorMessage = error?.localizedDescription
                completion()
            }
        }
    
    
    private func uploadUser(_ user: User) async {
            let db = Firestore.firestore()
            
            do {
                try await db.collection("users").document(authResult!.user.uid).setData(from: user)
                print("User uploaded to Firestore successfully.")
                try await Firestore.firestore().collection("users").document(authResult!.user.uid).updateData(["keywordsForLookup": user.keywordsForLookup])
            } catch let error {
                print("Error uploading user to Firestore: \(error.localizedDescription)")
            }
        }
    
    func fetchUser(completion: @escaping () -> Void) {
            guard let uid = self.userSession?.uid else { return }
            
            service.fetchUser(withUid: uid) { user in
                //print(user)
                self.currUser = user
                UserData.shared.username = self.currUser!.username
                //print(UserData.shared.username)
            }
        }
    
    func fetchUserInformation(uid: String, completion: @escaping (User?) -> Void) {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)
        
        userDocument.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    completion(userData)
                } catch {
                    print("Error decoding user: \(error)")
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    private let db = Firestore.firestore()
    func joinGlobal(completion: @escaping (Error?) -> Void) {
        Task {
            let username = username // Access the username asynchronously
            var enabled = true
            let db = Firestore.firestore()
            
            // Fetch the ticketFormat from the database
            db.collection("groups").document("Global").getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    completion(error)
                } else if let document = document, document.exists {
                    guard let ticketFormat = document.get("ticketFormat") as? [Int] else {
                        print("Ticket format not found or is of incorrect type")
                        completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Ticket format not found"]))
                        return
                    }
                    
                    db.collection("groups").document("Global").collection("members").getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            completion(error)
                        } else {
                            let rank = (snapshot?.documents.count)! + 1 ?? -99
                            let userTicketsCollection = db.collection("users").document(Auth.auth().currentUser!.uid).collection("tickets").document("week").collection("currentWeekTickets")
                            let ticket = Ticket(username: username, uid: Auth.auth().currentUser!.uid, groupID: "Global", groupNumber: 0, dateCreated: Timestamp(date: Date()), totalWon: 0, totalPotentialWon: 0, groupName: "Global", rank: String(rank), isEnabled: enabled, groupAdmin: "GOD", ticketFormat: ticketFormat) // Using ticketFormat from database
                            do {
                                let _ = try userTicketsCollection.addDocument(from: ticket) { error in
                                    if let error = error {
                                        print("Error uploading group: \(error)")
                                        completion(error)
                                    } else {
                                        print("Joined group successfully!")
                                        self.db.collection("groups").document("Global").collection("members").document(Auth.auth().currentUser!.uid).setData(["userID": Auth.auth().currentUser!.uid])
                                        completion(nil)
                                    }
                                }
                            } catch {
                                print("Error encoding group: \(error)")
                                completion(error)
                            }
                        }
                    }
                } else {
                    print("Document does not exist")
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey : "Document not found"]))
                }
            }
        }
    }


//
//    func signOut() {
//        authenticationState = .unauthenticated
//        userSession = nil
//        currUser = nil
//        try? Auth.auth().signOut()
//    }
    
    func signOut() {
        userSession = nil
        try? Auth.auth().signOut()
    }
    
    func deleteAccount() async -> Bool {
        Task {
            try await Auth.auth().currentUser?.delete()
        }
        userSession = nil
        return true
    }
    
    func uploadProfileImage(_ image: UIImage) {
        print("entered1")
        guard let uid = Auth.auth().currentUser else {return }
        print("entered01")
        imageUploader.uploadImage(use: "profile", image: image) { profileImageUrl in
            print("entered2")
            Firestore.firestore().collection("users").document(uid.uid).updateData(["profileImageUrl": profileImageUrl]) { _ in
                print("entered3")
                
            }
            
        }
        
    }
    
    
}
