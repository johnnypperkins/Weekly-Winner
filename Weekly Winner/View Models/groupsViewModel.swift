//
//  groupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/16/23.
//
import Firebase


class groupsViewModel: ObservableObject {
    
    @Published var queriedGroups: [Ticket] = []
    @Published var groupNames: [Group] = []
    @Published var rankedGroupTickets: [Group] = []
    private let grpService = groupService()
    
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
    
    func fetchGroupTickets(group: String) {
        grpService.getRankedTickets(groupN: group) { [weak self] (groups, error) in
                if let error = error {
                    // Handle error
                    print("Error fetching groups: \(error)")
                } else if let groups = groups {
                    DispatchQueue.main.async {
                        self?.rankedGroupTickets = groups
                    }
                }
            }
        }
    
    func joinGroup(group: Ticket) {
        
        grpService.joinGroup(userID: Auth.auth().currentUser!.uid, group: group)
    }
    
    func fetchGroupNames() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        let groupsCollection = db.collection("users").document(currentUser.uid).collection("groups")
        
        groupsCollection.order(by: "groupNumber").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching groups: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, error == nil else { return }
            
            groupNames = documents.compactMap { snapshot in
                print(snapshot)
                return try? snapshot.data(as: Group.self)
            }
        }
    }

}
