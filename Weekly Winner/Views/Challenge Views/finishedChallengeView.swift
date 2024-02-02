//
//  finishedChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 2/1/24.
//

import Foundation
import SwiftUI

struct finishedCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.currentChallenges, id: \.customID) { challenge in
                if challenge.status == "win" || challenge.status == "loss" || challenge.status == "push" {
                    // accepted and started
                    NavigationLink {
                        inActionChallengeView(challenge: challenge, viewModel: inActionChallengeViewModel(challenge: challenge))
                    } label: {
                        pendingOption1(challenge: challenge, opponentChallenge: viewModel.opponentChallenges.first(where: { $0.customID == challenge.customID}) ?? challenge)
                    }
                }
            }
        }
        .onAppear() {
            viewModel.fetchChallenges {}
        }
        .refreshable {
            viewModel.fetchChallenges {}
        }
    }
}
