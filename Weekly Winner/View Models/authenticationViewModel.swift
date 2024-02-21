//
//  authenticationViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/8/23.
//

import Firebase
import FirebaseFirestore

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

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
    @Published var tmpUser: User?
    
//    @Published var usernameTaken = false
    
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
    
    @Published var usernameTaken = false
    @Published var updateURL: String = ""
    
    @Published var currentVersion = "2.0.2"
    
    fileprivate var currentNonce: String?


    func checkUsernameAvailability(potentialUsername: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let normalizedUsername = potentialUsername.lowercased()

        db.collection("users").whereField("username", isEqualTo: normalizedUsername)
          .getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error checking username availability: \(error)")
                completion() // or handle the error appropriately
            } else {
                if let snapshot = querySnapshot, snapshot.isEmpty {
                    self.usernameTaken = false
                    completion()
                } else {
                    self.usernameTaken = true
                    completion()
                }
            }
        }
    }
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser() {}
        
    }
    
    func checkVerification(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload { error in
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                completion(false)
            } else {
                let isVerified = Auth.auth().currentUser?.isEmailVerified ?? false
                completion(isVerified)
            }
        }
    }
    
    enum AuthenticationError: Error {
      case tokenError(message: String)
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
                  let appleInTestingStage = document["appleCanTest"] as? Bool,
                  let updateURL2 = document["updateURL"] as? String else {
                print("Document not found or fields missing")
                completion()
                return
            }
        print("DATABASE VERSION", version)
        print("IOS VERSION", self.currentVersion)
            
        if self.currentVersion != version && appleInTestingStage == false {
                self.updateURL = updateURL2
                completion()
            } else {
                completion()
            }
        }
    }

    func sendPromoBucks(to username: String, from ownUsername: String) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        if username != "" {
            usersCollection.whereField("username", isEqualTo: username.lowercased()).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let userRef = usersCollection.document(document.documentID)
                        
                        userRef.updateData([
                            "poolBucks": FieldValue.increment(Double(2))
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("poolBucks successfully updated")
                                
                                let announcementsRef = userRef.collection("Misc").document("announcements").collection("announcementCollection")
                                announcementsRef.addDocument(data: [
                                    "status": "unSeen",
                                    "description": "\(ownUsername) used your promo code to sign up and you were awarded 2 poolBucks!",
                                    "announcementType": "promoCode",
                                    "timestamp": Timestamp(date: Date()) // Current timestamp
                                ]) { err in
                                    if let err = err {
                                        print("Error adding announcement document: \(err)")
                                    } else {
                                        print("Announcement successfully added")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName,.email]
        print("on sign in with apple")
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        print("made it")
        if case .failure(let failure) = result {
            errorMessage = failure.localizedDescription
        }
        else if case .success(let success) = result {
            print("made it too")
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                self.firstName = appleIDCredential.fullName?.givenName ?? ""
                self.lastName = appleIDCredential.fullName?.familyName ?? ""
                guard let nonce = currentNonce else{
                    fatalError("Invalid state: a login callback was received, but no login request was sent")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
            }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else{
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                Task{
                    authenticationState = .authenticating
                    do{
                        authResult = try await Auth.auth().signIn(with: credential)
                        
                        let firebaseUser = authResult!.user
                        authenticationState = .authenticated
                      print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
          //              self.userSession = firebaseUser
                        
                        service.fetchUser(uid: firebaseUser.uid) { user,success  in
                            print(user)
                            print(success)
                            if success == false {
                                let newUser = User(username: "", firstName: self.firstName, lastName: self.lastName, profileImageUrl: "", email: firebaseUser.email ?? "", dateJoined: Timestamp(date: Date()), instagram: "", promoCode: "", country: "",state: "", birthday: Timestamp(date: Date()), gender: "", poolCoins: 100.0, poolBucks: 0.0, paymentVerified: "false")
                                self.currUser = newUser
                                Task{
                                    await self.uploadUser(newUser)
                                }
                                self.joinGlobal { error in
                                    
                                }
                            }
                            else{
                                self.userSession = firebaseUser
                                self.fetchUser {
          print("fetched user")
                                }
                            }
                        }
                    }
                    catch{
                        print("Error authenticating: \(error.localizedDescription)")
                          print(error.localizedDescription)
                          self.errorMessage = error.localizedDescription
                          return
                        
                    }
                }
            }
        }
    }
    
    func signInWithGoogle() async  {
        authenticationState = .authenticating
        guard let clientID = FirebaseApp.app()?.options.clientID else {
          fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
          print("There is no root view controller!")
          return
        }

          do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken
              firstName = userAuthentication.user.profile?.givenName ?? ""
              lastName = userAuthentication.user.profile?.familyName ?? ""
              print(firstName)
              print(lastName)

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)

            authResult = try await Auth.auth().signIn(with: credential)
              let firebaseUser = authResult!.user
              authenticationState = .authenticated
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
//              self.userSession = firebaseUser
              
              service.fetchUser(uid: firebaseUser.uid) { user,success  in
                  print(user)
                  print(success)
                  if success == false {
                      let newUser = User(username: "", firstName: self.firstName, lastName: self.lastName, profileImageUrl: "", email: firebaseUser.email ?? "", dateJoined: Timestamp(date: Date()), instagram: "", promoCode: "", country: "",state: "", birthday: Timestamp(date: Date()), gender: "", poolCoins: 100.0, poolBucks: 0.0, paymentVerified: "false")
                      self.currUser = newUser
                      Task{
                          await self.uploadUser(newUser)
                      }
                      self.joinGlobal { error in
                          
                      }
                  }
                  else{
                      self.userSession = firebaseUser
                      self.fetchUser {
print("fetched user")
                      }
                  }
              }
              
              
            return
          }
          catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return
          }
      }
    
    func showMainScreen() {
        userSession = authResult!.user
        print("helllllllll\(userSession)")
        
    }
    
    func uploadSupplementaryData(country: String, birthday: Date, state: String, gender: String, username: String, instagram: String, promoCode: String) {
        guard let uid = Auth.auth().currentUser else {return }
        
//        Task{
//            await uploadUser(tmpUser!)
//        }
        joinGlobal { error in
            print(error)
        }
        
        Firestore.firestore().collection("users").document(uid.uid).updateData(["country": country]) { _ in
            
        }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["username": username]) { _ in
            
        }
        let timestamp = Timestamp(date: birthday)
        Firestore.firestore().collection("users").document(uid.uid).updateData(["birthday": timestamp]) { _ in
            
        }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["gender": gender]) { _ in
            
        }
        Firestore.firestore().collection("users").document(uid.uid).updateData(["state": state]) { _ in
            
        }
        if state != "Choose here" {
            Firestore.firestore().collection("users").document(uid.uid).updateData(["instagram": instagram]) { _ in
                
            }
            Firestore.firestore().collection("users").document(uid.uid).updateData(["promoCode": promoCode]) { _ in
                
            }
            
            
            
            let userTicketsCollection = Firestore.firestore()
                .collection("users")
                .document(uid.uid)
                .collection("tickets")
                .document("day")
                .collection("currentDayTickets")
            
            let userTicketsCollection2 = Firestore.firestore()
                .collection("users")
                .document(uid.uid)
                .collection("tickets")
                .document("week")
                .collection("currentWeekTickets")
            
            userTicketsCollection.getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Assuming there is only one document in this collection
                    if let document = querySnapshot?.documents.first {
                        document.reference.updateData(["username": username]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }
            
            userTicketsCollection2.getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Assuming there is only one document in this collection
                    if let document = querySnapshot?.documents.first {
                        document.reference.updateData(["username": username]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    
    func signUp(completion: @escaping () -> Void) async {
            authenticationState = .authenticating
            
            do {
                authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                //userSession = authResult!.user // added - Reid
                
                authResult?.user.sendEmailVerification { error in
                    if let error = error {
                        print("Error sending email verification \(error.localizedDescription)")
                    } else {
                        // Email sent
                    }
                }
                
                let user = authResult!.user
                
                let newUser = User(username: "", firstName: firstName, lastName: lastName, profileImageUrl: "", email: email, dateJoined: Timestamp(date: Date()), instagram: "", promoCode: "", country: "",state: "", birthday: Timestamp(date: Date()), gender: "", poolCoins: 100.0, poolBucks: 0.0, paymentVerified: "false")
                await uploadUser(newUser)
                
                authenticationState = .authenticated
                completion()
            } catch let error {
                // Handle signup error
                errorMessage = error.localizedDescription
                print("Signup error: \(error.localizedDescription)")
                authenticationState = .unauthenticated
                completion()
            }
        }
    
    
    
    func signIn(completion: @escaping () -> Void) async {
        authenticationState = .authenticating
        do {
            authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            // Assuming fetchUser() is also an async function. If it's not, consider making appropriate adjustments.
            
            self.userSession = authResult!.user  // Set placeholder user session
            
            // If fetchUser is async, you should await it and handle its completion differently.
            // Here, it's called with a completion handler assuming it's a non-async function.
            self.fetchUser() {
                // This block is executed when fetchUser completes.
                // You might need to handle success or failure here if fetchUser provides such information.
            }
            
            self.authenticationState = .authenticated
            print("sign in successful")
            completion()  // Sign-in successful, passing nil for the error
        } catch {
            print("Sign-in error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            completion()  // Pass the error to the completion handler
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
            
        service.fetchUser(uid: uid) { user,success  in
                //print(user)
            
            if success {
                self.username = user?.username ?? ""
                self.currUser = user
                self.username = user?.username ?? ""
                StaticUserData.shared.username = self.currUser?.username ?? ""
                
            }
            else{
                
            }
                //print(UserData.shared.username)
                //print(user)
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
            var enabled = false
            let db = Firestore.firestore()
            
            // Join Global Weekly
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
            
            // Join daily
            db.collection("groups").document("GlobalDaily").getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    completion(error)
                } else if let document = document, document.exists {
                    guard let ticketFormat = document.get("ticketFormat") as? [Int] else {
                        print("Ticket format not found or is of incorrect type")
                        completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "Ticket format not found"]))
                        return
                    }
                    
                    db.collection("groups").document("GlobalDaily").collection("members").getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                            completion(error)
                        } else {
                            let rank = (snapshot?.documents.count)! + 1 ?? -99
                            let userTicketsCollection = db.collection("users").document(Auth.auth().currentUser!.uid).collection("tickets").document("day").collection("currentDayTickets")
                            let ticket = Ticket(username: username, uid: Auth.auth().currentUser!.uid, groupID: "GlobalDaily", groupNumber: 0, dateCreated: Timestamp(date: Date()), totalWon: 0, totalPotentialWon: 0, groupName: "Daily", rank: String(rank), isEnabled: enabled, groupAdmin: "GOD", ticketFormat: ticketFormat) // Using ticketFormat from database
                            do {
                                let _ = try userTicketsCollection.addDocument(from: ticket) { error in
                                    if let error = error {
                                        print("Error uploading group: \(error)")
                                        completion(error)
                                    } else {
                                        print("Joined group successfully!")
                                        self.db.collection("groups").document("GlobalDaily").collection("members").document(Auth.auth().currentUser!.uid).setData(["userID": Auth.auth().currentUser!.uid])
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
