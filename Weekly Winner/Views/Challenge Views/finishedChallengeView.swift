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

struct completedCard: View { // inAction
    let challenge: DirectChallengeTicket
    @State private var opponentProfileImageURL = ""
    @ObservedObject var viewModel: challengeViewModel
    var body: some View {
        VStack {
            NavigationLink(destination: {
                acceptDirectChallenge(
                    viewModel: viewModel,
                    directChallengeTicket: challenge,
                    inAction: true)
                .background(K.finalColor.backgroundBlue)
            }, label: {
                VStack {
                    HStack {
                        profilePicDisplayView(dimension: 30, picURL: opponentProfileImageURL)
                            .padding(.leading)
                        
                        Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.receiverUsername : challenge.senderUsername)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                            
                        Spacer()
                        
                        currencyImage(currency: challenge.currencyChosen, dimension: 25)
                        
                        Text("\(String(format: "%.2f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount)) : \(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount, MLOdds: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderOdds : challenge.receiverOdds)))")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                    
                }.padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, maxHeight: 70)
                    .background(challenge.status == "win" ? K.finalColor.winningGreen : (challenge.status == "loss" ? K.finalColor.deleteRed : K.averageGray))
                    .cornerRadius(7.5)
                    .padding(.horizontal,15)
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
}


//struct finalizedCard: View {
//    let challenge: DirectChallengeTicket
//    
//    
//    @State private var opponentProfileImageURL = ""
//    var body: some View {
//        
//        VStack (spacing: 0){
//            HStack {
//                Spacer()
//                Text("\(challenge.status.capitalized) ")
//                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
//                    .foregroundColor(.white)
//                Spacer()
//            }.frame(height: 25)
//                .background(challenge.status == "win" ?  K.finalColor.winningGreen : (challenge.status == "loss" ? K.finalColor.deleteRed : K.averageGray))
//            
//            HStack {
//                HStack(spacing: 11) {
//                    VStack(alignment: .center, spacing: 10) {
//                        
//                        HStack {
//                            HStack (alignment: .center) {
//                                Text("\(Int(challenge.totalWon))")
//                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
//                                    .foregroundColor(challenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
//                                    .frame(width: 100 , height: 20, alignment: .center)
//                            }
//                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
//                            .background(K.finalColor.winningGreen.opacity(0.1))
//                            .cornerRadius(5)
//                            
//                        }
//
//                        Text("\(StaticUserData.shared.currentUser.username)")
//                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
//                            .foregroundColor(.white)
//                        
//                    }
//                }.frame(width: 150)
//                
//                Text("vs")
//                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
//                    .foregroundColor(.white)
//                
//                HStack(spacing: 11) {
//                    
//                    VStack(alignment: .center, spacing: 10) {
//                        
//                        HStack {
//       
//                            
//                            HStack (alignment: .center) {
//                                Text("\(Int(opponentChallenge.totalWon))")
//                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
//                                    .foregroundColor(opponentChallenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
//                                    .frame(width: 100 , height: 20, alignment: .center)
//                            }
//                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
//                            .background(K.finalColor.winningGreen.opacity(0.1))
//                            .cornerRadius(5)
//                            
//                        }
//                        
//                        
//                        Text("\(challenge.opponentUsername)")
//                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
//                            .foregroundColor(.white)
//                        
//                    }
//                }.frame(width: 150)
//               
//            }
//            .padding(EdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10))
//            Spacer()
//        }.frame(height: 120)
//            .background(K.finalColor.cardBlue)
//            .cornerRadius(10)
//            .padding(.horizontal,15)
//
//
//        
//        .onAppear {
//            fetchUserProfilePic(uid: challenge.challengerID) { (profileImageUrl, error) in
//                if let error = error {
//                    print("Error fetching profile image URL: \(error)")
//                   
//                } else if let profileImageUrl = profileImageUrl {
//                   //print("Profile image URL: \(profileImageUrl)")
//                    self.selfProfileImageURL = profileImageUrl
//                }
//            }
//            fetchUserProfilePic(uid: challenge.receiverIDs[0]) { (profileImageUrl, error) in
//                if let error = error {
//                    print("Error fetching profile image URL: \(error)")
//                   
//                } else if let profileImageUrl = profileImageUrl {
//                   //print("Profile image URL: \(profileImageUrl)")
//                    self.opponentProfileImageURL = profileImageUrl
//                }
//            }
//        }
//       
//    }
//}
 
