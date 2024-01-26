//
//  finalizeChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/10/24.
//

import Foundation
import SwiftUI
import Firebase
import Kingfisher

struct challengePage4: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var shouldNavigate = false
    @StateObject var authViewModel = authenticationViewModel()
    
    @State var profileImageURL: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                    VStack(alignment: .center) {
                            
                        HStack {
                            Image(viewModel.currencyChosen == "poolCoins" ? "poolCoin" : "poolBuck")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text(String(format: "%.2f", viewModel.wagerAmount))
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 50))
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Spacer()
                            HStack {
                                if StaticUserData.shared.currentUser.profileImageUrl != "" {
                                    KFImage(URL(string: StaticUserData.shared.currentUser.profileImageUrl))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                                Text("\(StaticUserData.shared.currentUser.username)")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18)).foregroundColor(K.finalColor.textWhite)
                                    .frame(width: 100)
                            }
                            
                            Text("vs")
                                .font(.custom(K.customFonts.lexendDecaLight, size: 12)).foregroundColor(K.finalColor.textWhite)
                                .padding(.horizontal,10)
                            
                            HStack (spacing: 0){
                                Text("\(viewModel.opponentUsername)")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18)).foregroundColor(K.finalColor.textWhite)
                                    .frame(width: 100)
                                if viewModel.opponentProfilePicURL != "" {
                                    KFImage(URL(string: viewModel.opponentProfilePicURL))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                            }
                            
                            Spacer()
                        }
                    }
                        
                VStack{
                    challengeBetsDisplay(uid: StaticUserData.shared.currentUser.id!, viewModel: viewModel)
                }
            }
            
            Button(action: {
                viewModel.sendChallenge(username: authViewModel.username,
                    challengeTicket: ChallengeTicket(
                        customID: generateRandomString(length: 20),
                        username: authViewModel.username,
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
//                    if viewModel.errorMessage != "" {
//                        AppUtility.shared.showCustomAlert(alertType: .none, message: viewModel.errorMessage, actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.cancel) { action in
//                            
//                        }
//                    }
                }
                
            }, label: {
                HStack{
                    Spacer()
                    Text("Send Challenge")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                    .background(K.finalColor.winningGreen)
                    .cornerRadius(10)
                    .padding(.horizontal,16)
                    .padding(.bottom,20)
            })
            
            NavigationLink(destination: tabBarView(selection: .profile), isActive: $shouldNavigate) {}

        }.onAppear {
            fetchUserProfilePic(uid: viewModel.opponentID) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    viewModel.opponentProfilePicURL = profileImageUrl
                }
            }
        }
    }
}




