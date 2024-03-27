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
//                        NavigationLink {
//                            inActionChallengeView(challenge: challenge, viewModel: inActionChallengeViewModel(challenge: challenge))
//                        } label: {
//                            finalizedCard(challenge: challenge, opponentChallenge: viewModel.opponentChallenges.first(where: { $0.customID == challenge.customID})!)
//                        }
                        completedCard(challenge: challenge, viewModel: viewModel)

                    
                }
            }
        }.padding(.bottom, 80)
        .onAppear() {
            viewModel.fetchChallenges {}
//            viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
        .refreshable {
            viewModel.fetchChallenges {}
//            viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
    }
}

struct GlowEffect: ViewModifier {
    var color: Color
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: isAnimating ? 20 : 10, x: 0, y: 0)
            .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear() {
                isAnimating = true
            }
    }
}


struct completedCard: View {
    let challenge: DirectChallengeTicket
    @State private var opponentProfileImageURL = ""
    @ObservedObject var viewModel: challengeViewModel
    var displayAmount: String {
        if challenge.status == "win" {
            return "+ \(String(format: "%.2f",returnPotentialWinnings(wagerAmount: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount, MLOdds: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderOdds : challenge.receiverOdds)))"
        } else if challenge.status == "loss" {
            return "- \(String(format: "%.2f",challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount))"
        } else if challenge.status == "push" {
            return "\(String(format: "%.2f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount))"
        }
        return ""
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: {
                acceptDirectChallenge(
                    viewModel: viewModel,
                    directChallengeTicket: challenge,
                    inAction: true,
                    publicViewing: false)
                    .background(K.finalColor.backgroundBlue)
            }, label: {
                VStack (spacing: 3){
                    HStack {
                        profilePicDisplayView(dimension: 30, picURL: opponentProfileImageURL)
                            .padding(.leading)
                        
                        Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.receiverUsername : challenge.senderUsername)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                            
                        Spacer()
                        
                        currencyImage(currency: challenge.currencyChosen, dimension: 25)
                        
                        Text(displayAmount)
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                            .padding(.horizontal, 3)
                            .background(challenge.status == "win" ? K.finalColor.winningGreen : (challenge.status == "loss" ? K.finalColor.deleteRed : K.averageGray))
                            .cornerRadius(5)
                            .padding(.trailing)

                    }.padding(.top)
                    
                    Rectangle().fill(Color.white).frame(width: 250, height: 1)

                    HStack {
                        Spacer()
                        Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderTeamName : challenge.receiverTeamName) \(returnSpreadStringStatic(betType: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderBetType : challenge.receiverBetType, spread: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderBetLine : challenge.receiverBetLine))")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white)
                            
//                            .background(challenge.status == "win" ? K.finalColor.winningGreen : (challenge.status == "loss" ? K.finalColor.deleteRed : K.averageGray)).cornerRadius(5)
                            .padding(.vertical, 4)
                        Spacer()
                    }

                }
//                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: 75)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal,15)
                // Apply the GlowEffect here
//                .modifier(GlowEffect(color: glowColorForStatus(challenge.status)))
            })
                    }.onAppear() {
            fetchUserProfilePic(uid: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.receiverID : challenge.senderID) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                } else if let profileImageUrl = profileImageUrl {
                    self.opponentProfileImageURL = profileImageUrl
                }
            }
        }
    }
    
    private func glowColorForStatus(_ status: String) -> Color {
        switch status {
        case "win":
            return K.finalColor.winningGreen
        case "loss":
            return K.finalColor.deleteRed
        default:
            return K.averageGray
        }
    }
}


 
