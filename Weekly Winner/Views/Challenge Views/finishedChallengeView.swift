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
                    if viewModel.opponentChallenges.contains(where: { $0.customID == challenge.customID}) {
                        NavigationLink {
                            inActionChallengeView(challenge: challenge, viewModel: inActionChallengeViewModel(challenge: challenge))
                        } label: {
                            finalizedCard(challenge: challenge, opponentChallenge: viewModel.opponentChallenges.first(where: { $0.customID == challenge.customID})!)
                        }
                    }
                }
            }
        }.padding(.bottom, 80)
        .onAppear() {
            viewModel.fetchChallenges {}
            viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
        .refreshable {
            viewModel.fetchChallenges {}
            viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
    }
}


struct finalizedCard: View {
    let challenge: ChallengeTicket
    let opponentChallenge: ChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    var body: some View {
        
        VStack (spacing: 0){
            HStack {
                Spacer()
                Text("\(challenge.status.capitalized) ")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 25)
                .background(challenge.status == "win" ?  K.finalColor.winningGreen : (challenge.status == "loss" ? K.finalColor.deleteRed : K.averageGray))
            
            HStack {
                HStack(spacing: 11) {
                    VStack(alignment: .center, spacing: 10) {
                        
                        HStack {
                            HStack (alignment: .center) {
                                Text("\(Int(challenge.totalWon))")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(challenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                    .frame(width: 100 , height: 20, alignment: .center)
                            }
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(K.finalColor.winningGreen.opacity(0.1))
                            .cornerRadius(5)
                            
                        }

                        Text("\(StaticUserData.shared.currentUser.username)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                        
                    }
                }.frame(width: 150)
                
                Text("vs")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                
                HStack(spacing: 11) {
                    
                    VStack(alignment: .center, spacing: 10) {
                        
                        HStack {
       
                            
                            HStack (alignment: .center) {
                                Text("\(Int(opponentChallenge.totalWon))")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(opponentChallenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                    .frame(width: 100 , height: 20, alignment: .center)
                            }
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(K.finalColor.winningGreen.opacity(0.1))
                            .cornerRadius(5)
                            
                        }
                        
                        
                        Text("\(challenge.opponentUsername)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                        
                    }
                }.frame(width: 150)
               
            }
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }.frame(height: 120)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal,15)


        
        .onAppear {
            fetchUserProfilePic(uid: challenge.challengerID) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    self.selfProfileImageURL = profileImageUrl
                }
            }
            fetchUserProfilePic(uid: challenge.receiverIDs[0]) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    self.opponentProfileImageURL = profileImageUrl
                }
            }
        }
       
    }
}
 
