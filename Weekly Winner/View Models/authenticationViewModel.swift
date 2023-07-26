//
//  authenticationViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/8/23.
//

import Firebase


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

    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser()
    }
    
    func signUp() async {
            authenticationState = .authenticating
            
            do {
                authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                userSession = authResult!.user // added - Reid
                let user = authResult!.user
                
                
                
                let newUser = User(username: username, firstName: firstName, lastName: lastName, profileImageUrl: "", email: email)
                await uploadUser(newUser)
                
                authenticationState = .authenticated
            } catch let error {
                // Handle signup error
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

                    self.fetchUser() // sets user to user instead of nil

                    self.authenticationState = .authenticated
                    print("sign in successful")
                }
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
    
    func fetchUser() {
            guard let uid = self.userSession?.uid else { return }
            
            service.fetchUser(withUid: uid) { user in
                print(user)
                self.currUser = user
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

    
    func signOut() {
        authenticationState = .unauthenticated
        userSession = nil
        currUser = nil
        try? Auth.auth().signOut()
    }
    
    
    
}
