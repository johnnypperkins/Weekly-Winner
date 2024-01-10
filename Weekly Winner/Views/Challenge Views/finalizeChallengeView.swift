//
//  finalizeChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/10/24.
//

import Foundation
import SwiftUI
import Firebase

struct challengePage4: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var shouldNavigate = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("\(viewModel.currencyChosen)")
                Text("\(viewModel.wagerAmount)")
                Text("\(viewModel.opponentUsername)")
                challengeBetsDisplay(uid: StaticUserData.shared.currentUser.id!, viewModel: viewModel)
            }
            
                
            Button(action: {
                viewModel.sendChallenge(
                    challengeTicket: ChallengeTicket(
                        customID: generateRandomString(length: 20),
                        username: StaticUserData.shared.username,
                        opponentUsername: viewModel.opponentUsername,
                        dateCreated: Timestamp(date: Date()),
                        wagerAmount: viewModel.wagerAmount,
                        currencyChosen: viewModel.currencyChosen,
                        totalPotentialWon: viewModel.totalPotentialWon,
                        totalWon: viewModel.totalWon,
                        status: challengeStatus.pendingAcceptance.rawValue,
                        challengerID: StaticUserData.shared.currentUser.id!,
                        receiverIDs: [viewModel.opponentID],
                        ticketFormat: viewModel.ticketFormat,
                        gameIDs: viewModel.selectedGameIDs)
                ) {
                    self.shouldNavigate = true
                }
            }, label: {
                HStack{
                    Spacer()
                    Text("Send Challenge")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.horizontal,16)
                    .padding(.bottom,20)
            })
            
            NavigationLink(destination: tabBarView(selection: .profile), isActive: $shouldNavigate) {}

        }
    }
}




