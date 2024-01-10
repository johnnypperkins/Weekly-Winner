//
//  finalizeChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/10/24.
//

import Foundation
import SwiftUI

struct challengePage4: View {
    @ObservedObject var viewModel: challengeViewModel
    var body: some View {
        NavigationStack {
            VStack {
                Text("\(viewModel.currencyChosen)")
                Text("\(viewModel.wagerAmount)")
                Text("\(viewModel.opponentUsername)")
                challengeBetsDisplay(uid: StaticUserData.shared.currentUser.id!, viewModel: viewModel)
            }
            

            
            
        }
    }
}


/*
 challenge: ChallengeTicket(
     username: StaticUserData.shared.username,
     opponentUsername: viewModel.opponentUsername,
     uid: StaticUserData.shared.currentUser.id!,
     dateCreated: Timestamp(date: Date()),
     wagerAmount: viewModel.wagerAmount,
     currencyChosen: viewModel.currencyChosen,
     totalPotentialWon: viewModel.totalPotentialWon,
     totalWon: viewModel.totalWon,
     status: challengeStatus.pendingAcceptance.rawValue,
     challengerID: StaticUserData.shared.currentUser.id!,
     receiverIDs: [viewModel.opponentID],
     ticketFormat: viewModel.ticketFormat,
     gameIDs: viewModel.selectedGameIDs)*/
