//
//  pastTicketsViewModel.swift
//  Weekly Winner
//
//  Created by Reid Brown on 4/12/24.
//

import Foundation

class PastTicketsViewModel: ObservableObject {
    @Published var pastUserTickets: [Ticket] = []
    private let betService = BetService()
    
    
    /// Loads all all previous user tickets
    func loadPastTickets(uid: String, completion: @escaping() -> Void) {
        betService.fetchPastTickets(uid: uid) { tickets in
            DispatchQueue.main.async {
                self.pastUserTickets = tickets
                completion()
            }
        }
    }
    
}

