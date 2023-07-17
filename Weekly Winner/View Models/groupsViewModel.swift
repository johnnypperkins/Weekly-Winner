//
//  groupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/16/23.
//
import Firebase


class groupsViewModel: ObservableObject {
    
    @Published var queriedGroups: [Ticket] = []
    @Published var groupNames: [String] = []
    
    private let db = Firestore.firestore()
    
    func fetchGroup(from keyword: String) {
        db.collection("groups").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedGroups = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Ticket.self)
            }
            print("here")
        }
        print("hereeeee")
    }
    
    func fetchGroupNames() {
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            
            let db = Firestore.firestore()
            let groupsCollection = db.collection("users").document(currentUser.uid).collection("groups")
            
            groupsCollection.getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching groups: \(error.localizedDescription)")
                    return
                }
                groupNames.removeAll()
                //var groupNames: [Group] = []
                
                for document in snapshot?.documents ?? [] {
                    if let groupName = document.data()["groupName"] as? String {
                        groupNames.append(groupName)
                    }
                }
                
            }
        }
    }
