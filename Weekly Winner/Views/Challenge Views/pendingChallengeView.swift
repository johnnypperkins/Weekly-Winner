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
                        pendingOption1(challenge: challenge, opponentChallenge: viewModel.opponentChallenges.first(where: { $0.customID == challenge.customID}) ?? challenge)
                    }
                    
                } else if challenge.status == "pendingAcceptance" && challenge.challengerID != StaticUserData.shared.currentUser.id {
                    // someone sent to you
                    if let tenMinutesAfterChallenge = Calendar.current.date(byAdding: .minute, value: 10, to: challenge.dateCreated.dateValue()) {
                        if Date() < tenMinutesAfterChallenge {
                            pendingOption2(viewModel: viewModel, challenge: challenge)
                        }
                    }
                } else if challenge.status == "pendingAcceptance" && challenge.challengerID == StaticUserData.shared.currentUser.id {
                    // you sent waiting acceptance
                    if let tenMinutesAfterChallenge = Calendar.current.date(byAdding: .minute, value: 10, to: challenge.dateCreated.dateValue()) {
                        if Date() < tenMinutesAfterChallenge {
                            pendingOption3(challenge: challenge)
                        } else {
                           pendingOption3Expired(challenge: challenge, viewModel: viewModel)
                        }
                    }
                }
                
                
                
            }
        }
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


struct pendingOption1: View {
    let challenge: ChallengeTicket
    let opponentChallenge: ChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                HStack {
                    HStack(spacing: 11) {
                        VStack(alignment: .center, spacing: 10) {
                            
                            HStack {
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
                                    Text("\(Int(opponentChallenge.totalPotentialWon))")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.potentialOrange)
                                        .frame(width: 45, height: 20, alignment: .center)
                                }
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .background(K.finalColor.potentialOrange.opacity(0.1))
                                .cornerRadius(5)
                                
                                HStack (alignment: .center) {
                                    Text("\(Int(opponentChallenge.totalWon))")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(challenge.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                        .frame(width: 45 , height: 20, alignment: .center)
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
                   
                } .frame(height: 70)
                    .frame(maxHeight: .infinity)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            }
        }

        .padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 75, maxHeight: 75)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)

        
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
        
        ZStack {
            HStack  {
                HStack {
                    Spacer()
                    ZStack {
                        VStack(spacing: 7.5) {
                            HStack (spacing: 4){
                                if opponentProfileImageURL != "" {
                                    KFImage(URL(string: opponentProfileImageURL))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 30, height: 30)
                                } else {
                                    Image(systemName: "photo.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .background(K.finalColor.tabSelectedBlue)
                                        .clipShape(Circle())
                                }
                                
                                Text("\(challenge.opponentUsername)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                            }
                            HStack {
                                if challenge.currencyChosen == "poolBucks" {
                                    Image("poolBuckSkewed")
                                        .resizable()
                                        .foregroundStyle(.green)
                                        .frame(width: 25, height: 25)
                                }
                                else{
                                    Image("poolCoin")
                                        .resizable()
                                        .foregroundStyle(.green)
                                        .frame(width: 25, height: 25)
                                }
                                Text("\(String(format: "%.2f", challenge.wagerAmount)) : \(String(format: "%.2f", challenge.wagerAmount*0.952))")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                            }
                        }.padding(.leading)
                    }
                    
                    
                    Spacer()
                }
                
                Spacer()
                HStack (spacing: 10) {
                    Rectangle()
                        .frame(width: 1, height: 80)
                        .foregroundColor(.white)
                    
                    VStack (spacing: 7.5) {
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
                        
                        if StaticUserData.shared.currentUser.poolBucks >= challenge.wagerAmount {
                            NavigationLink(destination: {acceptChallengeView(viewModel: pendingChallengeViewModel(challenge: challenge), challengeViewModel: viewModel, challenge: challenge)
                                
                            }, label: {
                                HStack {
                                    Text("View")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 80, height: 40)
                                .background(K.finalColor.winningGreen)
                                .cornerRadius(7.5)
                            }).onSubmit {
                                
                            }
                        } else {
                            HStack {
                                Text("Need")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            .frame(width: 80, height: 40)
                            .background(K.finalColor.potentialOrange)
                            .cornerRadius(7.5)
                        }
                    }
                }.padding(.trailing)
                
            }.padding(.vertical, 10)
                .frame(height: 100)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            HStack {
                VStack {
                    Spacer()
                    Text("Expires: \(toHHMMSS(from:challenge.dateCreated.dateValue()))")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                        .foregroundColor(K.finalColor.potentialOrange)
                        .padding(.leading, 4)
                        .padding(.bottom, 4)
                }
                Spacer()
            }
            
        }
        .padding(.horizontal, 15)
        .onAppear {
            fetchUserProfilePic(uid: StaticUserData.shared.currentUser.id!) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    self.selfProfileImageURL = profileImageUrl
                }
            }
            fetchUserProfilePic(uid: challenge.challengerID) { (profileImageUrl, error) in
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
        
        ZStack {
            VStack {
                HStack(spacing: 5) {
                    Text("Pending Acceptance: @\(challenge.opponentUsername)")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                        .foregroundColor(.white)
                }
                
            }.padding(.vertical, 10)
            
            HStack {
                VStack {
                    Spacer()
                    Text("Expires: \(toHHMMSS(from:challenge.dateCreated.dateValue()))")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                        .foregroundColor(K.finalColor.potentialOrange)
                        .padding(.leading, 4)
                        .padding(.bottom, 4)
                }
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 15)
    }
}

struct pendingOption3Expired: View {
    let challenge: ChallengeTicket
    let viewModel: challengeViewModel
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("Challenge with: @\(challenge.opponentUsername) expired.")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.red)
            }
            Button(action: {
                viewModel.reclaimFundFromExpiredChallenge(userID: StaticUserData.shared.currentUser.id!, opponentID: challenge.receiverIDs[0], challengeID: challenge.customID, reclaimAmount: challenge.wagerAmount) {
                    viewModel.fetchChallenges {
                        viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {}
                    }
                }
            }, label: {
                HStack {
                    Text("Reclaim Funds")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                }
                .frame(width: 160, height: 40)
                .background(K.finalColor.potentialOrange)
                .cornerRadius(7.5)
            })
            
        }.padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)
        .padding(.horizontal, 15)
    }
}


func toHHMMSS(from timestamp: Date) -> String {
    let calendar = Calendar.current
        // Add 5 minutes to the timestamp
        guard let futureDate = calendar.date(byAdding: .minute, value: 10, to: timestamp) else {
            // Handle the case where the date couldn't be created
            return "Error creating future date"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // Adjust if needed
        dateFormatter.dateFormat = "hh:mm:ss a" // 12-hour format with AM/PM
        return dateFormatter.string(from: futureDate)
}
