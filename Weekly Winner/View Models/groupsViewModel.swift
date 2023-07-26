//
//  groupsViewModel.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/16/23.
//
import Firebase


class groupsViewModel: ObservableObject {
    
    @Published var queriedGroups: [Group] = [] // Group99
    @Published var ticketGroupNames: [Ticket] = [] // Ticket99
    @Published var rankedGroupTickets: [Ticket] = [] // Ticket99
    
    @Published var canJoinGroup: Bool = true
    
    private let grpService = groupService()
    
    private let db = Firestore.firestore()
    
    
    func fetchGroup(from keyword: String) {
        db.collection("groups").whereField("keywordsForLookup", arrayContains: keyword).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {return}
            self.queriedGroups = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Group.self) // Group99
            }
            print("here")
        }
        print("hereeeee")
    }
    
    func fetchGroupTickets(ticket: String) {
        grpService.getRankedTickets(groupN: ticket) { [weak self] (tickets, error) in
                if let error = error {
                    // Handle error
                    print("Error fetching groups: \(error)")
                } else if let tickets = tickets {
                    DispatchQueue.main.async {
                        self?.rankedGroupTickets = tickets
                    }
                }
            }
        }
    
    func joinGroup(group: Group) { // Group99
        
        grpService.joinGroup(userID: Auth.auth().currentUser!.uid, group: group)
    }
    
    func checkIfGroupAlreadyJoined(group: Group, completion: @escaping (Bool) -> Void) {
        self.fetchGroupNames() {
            for groupsJoined in self.ticketGroupNames {
                if group.id == groupsJoined.groupID {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }


    func fetchGroupNames(completion: @escaping () -> Void) {
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
            
            self.ticketGroupNames = documents.compactMap { snapshot in
                print(snapshot)
                return try? snapshot.data(as: Ticket.self) // Ticket99
            }

            // Call the completion closure after fetching and processing
            completion()
        }
    }


}
