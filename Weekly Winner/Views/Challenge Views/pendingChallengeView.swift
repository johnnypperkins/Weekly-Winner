//
//  pendingChallengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/10/24.
//

import Foundation
import SwiftUI
import Kingfisher
import Firebase

struct pendingCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.currentChallenges, id: \.customID) { challenge in

                    if challenge.status == "inAction" {// challenge has begun
                        pendingOption1(challenge: challenge, viewModel: viewModel)
                    } else if challenge.status == "pendingAcceptance" && challenge.senderID != StaticUserData.shared.currentUser.id {// someone sent to you
                        if Date() < challenge.gameCommenceTime.dateValue() {
                            pendingOption2(viewModel: viewModel, challenge: challenge)
                        }
                    } else if challenge.status == "pendingAcceptance" && challenge.senderID == StaticUserData.shared.currentUser.id {// you sent to someone
                        if Date() < challenge.gameCommenceTime.dateValue() {
                            pendingOption3(challenge: challenge)
                        } else { // you sent to someone and its past expiration date of 10 min
                            pendingOption3Expired(challenge: challenge, viewModel: viewModel)
                        }
                    } else if challenge.status == "pendingPublicAcceptance" {
                        if Date() < challenge.gameCommenceTime.dateValue() {
                            pendingOption4(challenge: challenge, viewModel: viewModel)
                        } else { // you sent to someone and its past expiration date of 10 min
                            pendingOption4Expired(challenge: challenge, viewModel: viewModel)
                        }
                    }
                }
            }.padding(.bottom, 75)
        }
        .onAppear() {
            viewModel.fetchChallenges {
//                viewModel.fetchChallengeGames(matchingIDs: viewModel.gamesIDsInChallenges) { games in
//                    viewModel.gamesInChallenges = games ?? []
//                }
            }
            //viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
        .refreshable {
            viewModel.fetchChallenges {}
            //viewModel.fetchAllOpponentChallenges(userID: StaticUserData.shared.currentUser.id!) {}
        }
    }
}



struct pendingOption1: View { // inAction
    let challenge: DirectChallengeTicket
    @State private var opponentProfileImageURL = ""
    @ObservedObject var viewModel: challengeViewModel
    var body: some View {
        VStack {
            NavigationLink(destination: {
                acceptDirectChallenge(viewModel: viewModel, directChallengeTicket: challenge, inAction: true, publicViewing: false)
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
                        
                        VStack (alignment: .leading){
                            Text("Wager: ")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .padding(.trailing)
                            
                            Text("Win: ")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .padding(.trailing)
                        }
                        VStack (alignment: .leading){
                            Text("\(String(format: "%.2f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .padding(.trailing)
                            
                            Text("\(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderWagerAmount : challenge.receiverWagerAmount, MLOdds: challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderOdds : challenge.receiverOdds)))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .padding(.trailing)
                        }
                        
                    }
                    HStack{
                        Spacer()
                        if challenge.senderID == StaticUserData.shared.currentUser.id && challenge.senderBetLine > 0 {
                            Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderTeamName : challenge.receiverTeamName)  +\(String(format: "%.1f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderBetLine : challenge.receiverBetLine))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        else if challenge.senderID != StaticUserData.shared.currentUser.id && challenge.receiverBetLine > 0 {
                            Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderTeamName : challenge.receiverTeamName)  +\(String(format: "%.1f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderBetLine : challenge.receiverBetLine))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        else {
                            Text("\(challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderTeamName : challenge.receiverTeamName)  \(String(format: "%.1f", challenge.senderID == StaticUserData.shared.currentUser.id ? challenge.senderBetLine : challenge.receiverBetLine))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        
                    }
                        
                    
                }.padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 70, maxHeight: 70)
                    .background(K.finalColor.cardBlue)
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
            print(challenge)
        }
        
    }
}

struct pendingOption2: View { // awaiting your response
    @ObservedObject var viewModel: challengeViewModel

    let challenge: DirectChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    @State var showingSheet = false
    
    @State var declineConfirm: Bool = false
    
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
                                
                                Text("\(challenge.senderUsername)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                            }
                            HStack {
                                currencyImage(currency: "poolBucks", dimension: 25)
                                
                                Text("\(String(format: "%.2f", challenge.receiverWagerAmount)) : \(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challenge.receiverWagerAmount, MLOdds: challenge.receiverOdds)))") // NEED TO FIX
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
                        if !declineConfirm {
                            Button(action: {
                                declineConfirm = true
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
                        } else {
                            Button(action: {
                                viewModel.respondToChallenge(acceptedChallenge: false, challengeOG: challenge, publicChallenge: false, receiverBet: ["":""]) {
                                    viewModel.fetchChallenges {}
                                }
                            }, label: {
                                HStack {
                                    Text("Confirm")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 80, height: 40)
                                .background(K.finalColor.deleteRed)
                                .cornerRadius(7.5)
                            })
                        }

                        NavigationLink(destination: {
                            acceptDirectChallenge(viewModel: viewModel, directChallengeTicket: challenge, inAction: false, publicViewing: false)
                                .background(K.finalColor.backgroundBlue)
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

                    }
                }.padding(.trailing)
                
            }
            HStack {
                VStack {
                    Text("Expires: \(toHHMMSS(from:challenge.gameCommenceTime.dateValue()))")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(K.finalColor.deleteRed)
                        .cornerRadius(5, corners: .bottomRight)
                    Spacer()
                }
                Spacer()
            }
            
        }
        
        .frame(height: 100)
        .background(K.finalColor.cardBlue)
        .cornerRadius(10)
        .padding(.horizontal, 15)
        .onAppear {
            declineConfirm = false
            fetchUserProfilePic(uid: StaticUserData.shared.currentUser.id!) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    self.selfProfileImageURL = profileImageUrl
                }
            }
            fetchUserProfilePic(uid: challenge.senderID) { (profileImageUrl, error) in
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

struct pendingOption3: View { // awaiting other persons response
    let challenge: DirectChallengeTicket
    var body: some View {
        
        ZStack {
            VStack {
                HStack(spacing: 5) {
                    Text("Pending Acceptance: @\(challenge.receiverUsername)")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                        .foregroundColor(.white)
                }
                
            }.padding(.vertical, 10)
            
            HStack {
                VStack {
                    Text("Expires: \(toHHMMSS(from:challenge.gameCommenceTime.dateValue()))")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(K.finalColor.deleteRed)
                        .cornerRadius(5, corners: .bottomRight)
                    Spacer()
                }
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 15)
    }
}

struct pendingOption3Expired: View { // didnt respond fast enough
    let challenge: DirectChallengeTicket
    let viewModel: challengeViewModel
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("Challenge with: @\(challenge.receiverUsername) expired.")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.red)
            }
            Button(action: {
                viewModel.reclaimFundFromExpiredChallenge(senderID: StaticUserData.shared.currentUser.id!, receiverID: challenge.receiverID, customID: challenge.customID, reclaimAmount: challenge.senderWagerAmount, sentToPublic: false) {
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

struct pendingOption4: View { // didnt get response from public
    let challenge: DirectChallengeTicket
    let viewModel: challengeViewModel
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 5) {
                    Text("Pending Public Acceptance")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                        .foregroundColor(.white)
                }
                
            }.padding(.vertical, 10)
            
            HStack {
                VStack {
                    Text("Expires: \(toHHMMSS(from:challenge.gameCommenceTime.dateValue()))")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(K.finalColor.deleteRed)
                        .cornerRadius(5, corners: .bottomRight)
                    Spacer()
                }
                Spacer()
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 15)
    }
}

struct pendingOption4Expired: View { // didnt get response from public
    let challenge: DirectChallengeTicket
    let viewModel: challengeViewModel
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("Challenge with public expired.")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.red)
            }
            Button(action: {
                viewModel.reclaimFundFromExpiredChallenge(senderID: StaticUserData.shared.currentUser.id!, receiverID: challenge.receiverID, customID: challenge.customID, reclaimAmount: challenge.senderWagerAmount, sentToPublic: true) {
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



struct publicWager: View { // public challenges you can accept
    @ObservedObject var viewModel: challengeViewModel

    let challenge: DirectChallengeTicket
    @State private var selfProfileImageURL = ""
    @State private var opponentProfileImageURL = ""
    @State var showingSheet = false
    
    @State var declineConfirm: Bool = false
    
    var betLineFormatted: String {
        var extra = ""
        if challenge.receiverBetType == .over {
            extra = "o"
        } else if challenge.receiverBetType == .under {
            extra = "u"
        } else if challenge.receiverBetLine > 0 {
            extra = "+"
        }
        
        if challenge.receiverBetLine == 0 {
            return "ML"
        } else {
            if isWholeNumber(challenge.receiverBetLine) {
                return "\(extra)\(String(format: "%.0f", challenge.receiverBetLine))"
            } else {
                return "\(extra)\(String(format: "%.1f", challenge.receiverBetLine))"
            }
        }
        
    }
    
    var body: some View {
        if challenge.senderID != StaticUserData.shared.currentUser.id {
            NavigationLink(destination: {
                acceptDirectChallenge(viewModel: viewModel, directChallengeTicket: challenge, inAction: false, publicViewing: false)
                    .background(K.finalColor.backgroundBlue)
            }, label: {
                ZStack {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 7.5) {
                            HStack (spacing: 4){
                                Text("\(challenge.receiverTeamName) \(betLineFormatted) (\(challenge.receiverOdds))")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                            }
                            HStack {
                                currencyImage(currency: "poolBucks", dimension: 25)
                                
                                Text("\(String(format: "%.2f", challenge.receiverWagerAmount)) : \(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challenge.receiverWagerAmount, MLOdds: challenge.receiverOdds)))") // NEED TO FIX
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                    .foregroundColor(.white)
                                
                                VStack (spacing: 7.5) {
                                    
                                }
                            }
                        }
                        Spacer()
                    }
                        
                    HStack {
                        VStack {
                            Text("Expires: \(toHHMMSS(from:challenge.gameCommenceTime.dateValue()))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(K.finalColor.deleteRed)
                                .cornerRadius(5, corners: .bottomRight)
                            Spacer()
                                
                        }
                        Spacer()
                    }
                    
                }
                .frame(height: 100)
                .background(K.finalColor.cardBlue)
                .cornerRadius(10)
                .padding(.horizontal, 15)
                .padding(.bottom, 10)
            })
        } else {
            ZStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 7.5) {
                        HStack (spacing: 4){
                            Text("\(challenge.receiverTeamName) \(betLineFormatted) (\(challenge.receiverOdds))")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                        }
                        HStack {
                            currencyImage(currency: "poolBucks", dimension: 25)
                            
                            Text("\(String(format: "%.2f", challenge.receiverWagerAmount)) : \(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challenge.receiverWagerAmount, MLOdds: challenge.receiverOdds)))") // NEED TO FIX
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                            
                            VStack (spacing: 7.5) {
                                
                            }
                        }
                    }
                    Spacer()
                }
                    
                VStack {
                    HStack {
                        Text("Expires: \(toHHMMSS(from:challenge.gameCommenceTime.dateValue()))")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(K.finalColor.deleteRed)
                            .cornerRadius(5, corners: .bottomRight)
                        Spacer()
                        
                        
                        Text("Your Challenge")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 8))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(K.finalColor.potentialOrange)
                            .cornerRadius(5, corners: .bottomLeft)
                    }
                    Spacer()
                }
                
            }
            .frame(height: 100)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
        }
        
    }
}


struct currencyImage: View {
    let currency: String
    let dimension: Int
    var body: some View {
        if currency == "poolBucks" {
            Image("poolBuck")
                .resizable()
                .foregroundStyle(.green)
                .frame(width: CGFloat(dimension), height: CGFloat(dimension))
        } else {
            Image("poolCoin")
                .resizable()
                .foregroundStyle(.green)
                .frame(width: CGFloat(dimension), height: CGFloat(dimension))
        }
    }
}

func toHHMMSS(from timestamp: Date) -> String {
    let calendar = Calendar.current
    
    guard let futureDate = calendar.date(byAdding: .minute, value: 0, to: timestamp) else {
        // Handle the case where the date couldn't be created
        return "Error creating future date"
    }

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current // Adjust if needed
    dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss a" // Include date in the format
    return dateFormatter.string(from: futureDate)
}



struct profilePicDisplayView: View {
    let dimension: Int
    let picURL: String
    
    var body: some View {
        
        if picURL != "" {
            KFImage(URL(string: picURL))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: CGFloat(dimension), height: CGFloat(dimension))
        } else {
            Image(systemName: "photo.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: CGFloat(dimension), height: CGFloat(dimension))
                .background(K.finalColor.tabSelectedBlue)
                .clipShape(Circle())
        }
    }
}
