////
////  finalizeChallengeView.swift
////  Weekly Winner
////
////  Created by Reid Brown (Test) on 1/10/24.
////
//
//import Foundation
//import SwiftUI
//import Firebase
//import Kingfisher
//
//struct challengePage4: View {
//    @ObservedObject var viewModel: challengeViewModel
//    @State private var shouldNavigate = false
//    @StateObject var authViewModel = authenticationViewModel()
//    
//    @State var profileImageURL: String = ""
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                payoutHeader(currencyChosen: $viewModel.currencyChosen, wagerAmount: $viewModel.wagerAmount)
//                    .padding(.top)
//                    
//                versusHeader(opponentUsername: viewModel.opponentUsername, opponentProfilePic: viewModel.opponentProfilePicURL)
//                
//                VStack{
//                    challengeBetsDisplay(uid: StaticUserData.shared.currentUser.id!, viewModel: viewModel)
//                }
//            }
//            
//            Button(action: {
//                viewModel.sendChallenge(username: authViewModel.username,
//                    challengeTicket: ChallengeTicket(
//                        customID: generateRandomString(length: 20),
//                        username: authViewModel.username,
//                        opponentUsername: viewModel.opponentUsername,
//                        dateCreated: Timestamp(date: Date()),
//                        wagerAmount: viewModel.wagerAmount,
//                        currencyChosen: viewModel.currencyChosen,
//                        totalPotentialWon: viewModel.totalPotentialWon,
//                        totalWon: viewModel.totalWon,
//                        status: challengeStatus.pendingAcceptance.rawValue,
//                        challengerID: StaticUserData.shared.currentUser.id!,
//                        receiverIDs: [viewModel.opponentID],
//                        ticketFormat: viewModel.ticketFormat,
//                        gameIDs: viewModel.selectedGameIDs,
//                        gamesToPlay: viewModel.totalBetArrays.count*2,
//                    gamesPlayed: 0)
//                    
//                ) {
//                    self.shouldNavigate = true
//                    viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {}
//
//                }
//                
//            }, label: {
//                HStack{
//                    Spacer()
//                    Text("Send Challenge")
//                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
//                        .foregroundColor(.white)
//                    Spacer()
//                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
//                    .background(K.finalColor.winningGreen)
//                    .cornerRadius(10)
//                    .padding(.horizontal,16)
//                    .padding(.bottom,20)
//            })
//            
//            NavigationLink(destination: tabBarView(selection: .challenges), isActive: $shouldNavigate) {}
//
//        }.onAppear {
//            fetchUserProfilePic(uid: viewModel.opponentID) { (profileImageUrl, error) in
//                if let error = error {
//                    print("Error fetching profile image URL: \(error)")
//                   
//                } else if let profileImageUrl = profileImageUrl {
//                   //print("Profile image URL: \(profileImageUrl)")
//                    viewModel.opponentProfilePicURL = profileImageUrl
//                }
//            }
//        }
//    }
//}
//
//struct versusHeader: View {
//    let opponentUsername: String
//    let opponentProfilePic: String
//    var body: some View {
//        VStack (spacing: 0){
//            HStack (spacing: 2) {
//                Spacer()
//                if StaticUserData.shared.currentUser.profileImageUrl != "" {
//                    KFImage(URL(string: StaticUserData.shared.currentUser.profileImageUrl))
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .clipShape(Circle())//.padding(.leading, 40)
//                } else {
//                    Image(systemName: "person.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .clipShape(Circle())//.padding(.leading, 40)
//                }
//                Text("\(StaticUserData.shared.currentUser.username)")
//                    .font(.custom(K.customFonts.lexendDecaMedium, size: 22)).foregroundColor(K.finalColor.textWhite)
//                    .padding(.leading, 4)
//                Spacer()
//            }.padding(.top, 7.5)
//            HStack {
//                Spacer()
//                Text("vs")
//                    .font(.custom(K.customFonts.lexendDecaLight, size: 12)).foregroundColor(K.finalColor.textWhite)
//                    .padding(.horizontal,10)
//                Spacer()
//            }
//            HStack (spacing: 2){
//                Spacer()
//                Text("\(opponentUsername)")
//                    .font(.custom(K.customFonts.lexendDecaMedium, size: 22)).foregroundColor(K.finalColor.textWhite).padding(.trailing, 4)
//                    //.frame(width: 100)
//                if opponentProfilePic != "" {
//                    KFImage(URL(string: opponentProfilePic))
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .clipShape(Circle())//.padding(.trailing, 40)
//                } else {
//                    Image(systemName: "person.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .clipShape(Circle())//.padding(.trailing, 40)
//                }
//                Spacer()
//            }.padding(.bottom, 7.5)
//        }.frame(width: 343, height: 90).background(K.finalColor.cardBlue).cornerRadius(7.5)
//            .padding(.top, 5)
//    }
//}
