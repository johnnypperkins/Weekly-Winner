//
//  pendingChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/10/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct pendingCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.currentChallenges, id: \.customID) { challenge in
                if challenge.status == "inAction" {
                    // accepted and started
                    NavigationLink {
                        inActionChallengeView(challenge: challenge, viewModel: inActionChallengeViewModel(challenge: challenge))
                    } label: {
                        pendingOption1(challenge: challenge)
                    }

                    
                } else if challenge.status == "pendingAcceptance" && challenge.challengerID != StaticUserData.shared.currentUser.id {
                    // someone sent to you
                    pendingOption2(viewModel: viewModel, challenge: challenge)
                } else if challenge.status == "pendingAcceptance" && challenge.challengerID == StaticUserData.shared.currentUser.id {
                    // you sent waiting acceptance
                    pendingOption3(challenge: challenge)
                }
                
                
                
            }
        }
        .onAppear() {
            viewModel.fetchChallenges {}
        }
    }
}


struct pendingOption1: View {
    let challenge: ChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                HStack {
                    HStack(spacing: 11) {
                        VStack(alignment: .center, spacing: 10) {
                     
                                HStack (alignment: .center) {
                                    Text("\(Int(challenge.totalPotentialWon))")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.potentialOrange)
                                        .frame(width: 45, height: 20, alignment: .center)
                                }
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .background(K.finalColor.potentialOrange.opacity(0.1))
                                .cornerRadius(5)
                        
                            HStack (alignment: .center) {
                                Text("\(Int(challenge.totalWon))")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(challenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                    .frame(width: 45 , height: 20, alignment: .center)
                            }
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(K.finalColor.winningGreen.opacity(0.1))
                            .cornerRadius(5)
                           
                        }
                        HStack(spacing: 5) {
//                            if selfProfileImageURL != "" {
//                                KFImage(URL(string: selfProfileImageURL))
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .clipShape(Circle())
//                                    .frame(width: 35, height: 35)
//                            } else {
//                                Image(systemName: "photo.circle.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 35, height: 35)
//                                    .background(K.finalColor.tabSelectedBlue)
//                                    .clipShape(Circle())
//
//                            }
                            HStack {
                                Text("\(StaticUserData.shared.currentUser.username)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                               
                                Text("vs")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                    .foregroundColor(.white)
                                
                                Text("\(challenge.challengerID == StaticUserData.shared.currentUser.id ? challenge.opponentUsername : challenge.username)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                            }
                            
//                            if opponentProfileImageURL != "" {
//                                KFImage(URL(string: opponentProfileImageURL))
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .clipShape(Circle())
//                                    .frame(width: 35, height: 35)
//                            } else {
//                                Image(systemName: "photo.circle.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 35, height: 35)
//                                    .background(K.finalColor.tabSelectedBlue)
//                                    .clipShape(Circle())
//                            }
                            
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(height: 70)
                    .frame(maxHeight: .infinity)
                        HStack {
                            Image(systemName: "chevron.right") // Use any image you'd like
                                .resizable()
                                .frame(width: 7.5, height: 10) // Adjust size to your liking
                                .foregroundColor(.white ) // Choose color
                        }
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            }
        }

        .padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: 75)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)
        //.overlay(ownCard ? RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1) : RoundedRectangle(cornerRadius: 10).stroke(Color.clear, lineWidth: 0))
        //.shadow(color: ownCard ? Color.white : Color.clear, radius: ownCard ? 2.5 : 0, x: 0, y: 0)


        
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
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
        .background(K.finalColor.cardBlue)
        .cornerRadius(7.5)
        .padding(.horizontal,15)
    }
}

struct pendingOption2: View {
    @ObservedObject var viewModel: challengeViewModel
    let challenge: ChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    @State var showingSheet = false
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                if opponentProfileImageURL != "" {
                    KFImage(URL(string: opponentProfileImageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 35, height: 35)
                } else {
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .background(K.finalColor.tabSelectedBlue)
                        .clipShape(Circle())
                }

                Text("\(challenge.username) has challenged you")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
            }
            
            HStack{
                Text("Wager: \(String(format: "%.0f", challenge.wagerAmount))")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
                if challenge.currencyChosen == "poolBucks" {
                    Image(systemName: "dollarsign.square.fill")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: 18, height: 18)
                }
                else{
                    Image(systemName: "dollarsign.square.fill")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: 15, height: 15)
                }
                
                
            }
            
            HStack (spacing: 7.5) {
                NavigationLink(destination: {acceptChallengeView(viewModel: pendingChallengeViewModel(challenge: challenge), challengeViewModel: viewModel, challenge: challenge)
//                    viewModel.respondToChallenge(acceptedChallenge: true, challenge: challenge) {
////                        viewModel.fetchChallenges {}
//                        self.showingSheet.toggle()
//                    }
                }, label: {
                    HStack {
                        Text("Accept")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 40)
                    .background(K.finalColor.winningGreen)
                    .cornerRadius(7.5)
                })
//                .sheet(isPresented: $showingSheet, content: {
//                    acceptChallengeView(viewModel: pendingChallengeViewModel(challenge: challenge), challenge: challenge)
//                })
                
                Button(action: {
                    viewModel.respondToChallenge(acceptedChallenge: false, challenge: challenge) {
                        viewModel.fetchChallenges {}
                    }
                }, label: {
                    HStack {
                        Text("Decline")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 40)
                    .background(K.finalColor.deleteRed)
                    .cornerRadius(7.5)
                })
            }
        }.padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)
        .padding(.horizontal, 15)
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

struct pendingOption3: View {
    let challenge: ChallengeTicket
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("Waiting for @\(challenge.opponentUsername) to accept your challenge")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
            }
            
        }.padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)
        .padding(.horizontal, 15)
    }
}
