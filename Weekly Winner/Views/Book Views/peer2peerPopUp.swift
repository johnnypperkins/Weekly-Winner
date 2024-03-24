//
//  peer2peerPopUp.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 3/4/24.
//

import Foundation
import SwiftUI
import Kingfisher
import Firebase
import Combine

func returnTeamBetOn(betType: BetType, game: Game) -> String {
    switch betType {
    case .betHomeSpread:
        return game.homeTeam
    case .betAwaySpread:
        return game.awayTeam
    case .over:
        return "\(game.homeTeam) / \(game.awayTeam)"
    case .under:
        return "\(game.homeTeam) / \(game.awayTeam)"
    case .betHomeML:
        return game.homeTeam
    case .betAwayML:
        return game.awayTeam
    case .None:
        return ""
    }
}

struct peer2peerSubmitPage: View {
    let game: Game
    let betType: BetType
    @Binding var showingSheet: Bool
    @State var wagerAmount = 0.0
    @State  var selectedUser: User? = nil
    @State  var selectedFriend: Friend? = nil
    @State private var whichTab = "friends"
    @State var selectedUserID = ""
    @State var opponentUsername = ""
    @State var sendToFriends = false
    
    @ObservedObject var viewModel = peer2peerViewModel()


    var body: some View {
        VStack {
            VStack (spacing: 1){
                HStack (spacing: 0){
                    Button(action: {
                        whichTab = "friends"
                        
                    }) {
                        Text("Friends")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 30, alignment: .center)
                            .cornerRadius(5)
                    }
                    
//                    Button(action: {
//                        whichTab = "search"
//                    }) {
//                        Text("Search")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
//                            .foregroundColor(.white)
//                            .frame(width: 100, height: 30, alignment: .center)
//                            .cornerRadius(5)
//                    }
                    Button(action: {
                        whichTab = "public"
                    }) {
                        Text("Public")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 30, alignment: .center)
                            .cornerRadius(5)
                    }
                    
                }
                Rectangle()
                    .fill(Color.white) // Sets the rectangle's fill color to white
                    .frame(width: 70, height: 1.5)
                    .cornerRadius(1) // Apply rounded corners
                    .offset(x: whichTab == "friends" ? -100 : (whichTab == "search" ? 0 : 100), y: 0)
                    .animation(.easeInOut(duration: 0.35))
            }.padding(.bottom,2)
            if whichTab == "friends" {
                
                ForEach(viewModel.friends, id: \.id) { friend in
                    if friend.id != StaticUserData.shared.currentUser.id! {
                        
//
                        userBioFriend(friend: friend, selectedUserID: $selectedUserID, selectedFriend: $selectedFriend)
                    }
                }
                
            } 
//            else if whichTab == "search" {
//                searchUserView(game: game, viewModel: viewModel, betType: betType, wagerAmount: $wagerAmount, selectedUser: $selectedUser)
//            } 
            else if whichTab == "public" {
                VStack {
                            HStack {
                        
                                Text(sendToFriends ? "Send to All Friends" : "Send to Public")
                                    .font(Font.custom("LexendDeca-Medium", size: 18))
                                    .foregroundColor(.white)
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: sendToFriends)
                                Spacer()
                                Toggle("", isOn: $sendToFriends)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .white))
                                     // Adjust padding as needed
                            }.padding(.horizontal)
                            .frame(height: 50)
                            .background(sendToFriends ? Color.green : K.finalColor.cardBlue) // Change colors as needed
                            .cornerRadius(7.5)
                            
                                
                            
                        }
                        .frame(width: 345)
                        .animation(.easeInOut, value: sendToFriends)
            }
            twoWagers(game: game, viewModel: viewModel, betType: betType, wagerAmount: $wagerAmount, selectedFriend: $selectedFriend)
            peer2peerSlider(wagerAmount: $wagerAmount, selectedFriend: $selectedFriend, viewModel: viewModel, game: game, showingSheet: $showingSheet, whichTab: $whichTab, sendToFriends: $sendToFriends)
            Spacer()
        }.onChange(of: selectedFriend) { _ in
            viewModel.senderDirectTicket?.receiverID = selectedFriend?.id ?? ""
            viewModel.senderDirectTicket?.receiverUsername = selectedFriend?.username ?? ""
        }
        .onAppear() {
            viewModel.setSelectedBet(bet:
                    Bet(groupNumber: 1,
                        groupID: "",
                        betNumber: 0,
                        betType: betType,
                        teamBetOn: returnTeamBetOn(betType: betType, game: game), // make simple function to return team from bettype
                        betLine: Float(returnSpreadFromBetType(betType: betType, game: game)),
                        betOdds: Float(returnOddsFromBetType(betType: betType, game: game)), // prob some function somewhere will find
                        result: .notStarted,
                        gameID: game.idd!,
                        whichSport: game.whichSport,
                        timestamp: Timestamp(date: Date()),
                        points_bought: 0))
            
            viewModel.setSenderDirectTicket(senderTicket: DirectChallengeTicket(
                customID: "", // WONT BE USED
                senderUsername: StaticUserData.shared.currentUser.username,
                senderID: StaticUserData.shared.currentUser.id!,
                senderOdds: returnOddsFromBetType(betType: betType, game: game),
                senderBetType: betType,
                
                senderBetLine: returnSpreadFromBetType(betType: betType, game: game),
                senderTeamName: returnTeamString(game: game, betType: betType),
                
                senderWagerAmount: -99, // WILL ADJUST

                receiverUsername: "", // WILL ADJUST
                receiverID: "", // WILL ADJUST
                receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game),
                receiverBetType: returnOppBetType(betType: betType),
                
                receiverBetLine: returnSpreadFromBetType(betType: returnOppBetType(betType: betType), game: game),
                receiverTeamName: returnTeamString(game: game, betType: returnOppBetType(betType: betType)),
                
                receiverWagerAmount: -99, // WILL ADJUST

                dateCreated: Timestamp(date: Date()),
                currencyChosen: "poolBucks",
                status: challengeStatus.pendingAcceptance.rawValue,
                gameIDs: [game.idd!],
                gameCommenceTime: game.commenceTime,
                challengeType: "straight1v1"
            ))
            
        }
    }
}

struct userBioFriend: View {
    var friend: Friend
    
    @State var checked = false
    @Binding var selectedUserID: String
    @Binding var selectedFriend: Friend?
    
    
    var body: some View {
        Button {
            
            if selectedUserID == friend.id {
                selectedUserID = ""
                selectedFriend = nil
            }
            else {
                selectedFriend = friend
                selectedUserID = friend.id
            }
          
        } label: {
            ZStack {
                VStack (spacing: 10) {
                    HStack {
                        HStack(spacing: 11) {
                            HStack(spacing: 0) {
                                
                                
                                HStack(spacing: 5) {
                                    if friend.profileImageURL != "" {
                                        KFImage(URL(string: friend.profileImageURL))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 24, height: 24)
                                    } else {
                                        Image(systemName: "photo.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 24, height: 24)
                                            .background(K.finalColor.tabSelectedBlue)
                                            .clipShape(Circle())
                                        
                                    }
                                    HStack(spacing: 0){
                                        Text("\(friend.username) ")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                            .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                        
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .frame(height: 24)
                            
                            Spacer()
                            
                            
                            
                            // Arrow
                            
                                Image(systemName: selectedUserID == friend.id ? "checkmark.square" : "square")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                                
                                
                            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            //.padding(.bottom,10)
                            
                        }
                    }
                    .padding(.vertical, 10)
                    .frame(width: 345, height: 44)
                    .background(selectedUserID == friend.id ? K.finalColor.otherPurple.opacity(0.35) : K.finalColor.cardBlue)
                    .cornerRadius(10)
            }
//            .onTapGesture {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                print("tapped also")
//            }
        }
    }
}

struct peer2peerSlider: View {
    @Binding var wagerAmount: Double
    @Binding var selectedFriend: Friend?
    @ObservedObject var viewModel: peer2peerViewModel
    let game: Game
    @Binding var showingSheet: Bool
    @Binding var whichTab: String
    @Binding var sendToFriends: Bool

    var body: some View {
        VStack (spacing: 5){
            if selectedFriend != nil || whichTab == "public" {
                    HStack {
                        Text("Wager Amount")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white)
                            .padding(.leading, 2)
                        Spacer()
                    }.padding(.top)
                    if StaticUserData.shared.currentUser.poolBucks >= 1 {
                        HStack {
                            VStack (spacing:0) {
                                Text("0")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.leading)
                            }
                            
                            Slider(value: $wagerAmount, in: 0.0...min(StaticUserData.shared.currentUser.poolBucks, 100), step: 1) { editing in
                                
                            }.accentColor(.white)
                                .padding()
                            VStack (spacing: 0) {
                                Text("\(String(format: "%.0f", min(StaticUserData.shared.currentUser.poolBucks, 100)))")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(.white)
                                    .padding(.trailing)

                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing)
                                
                            }
                        }.frame(height: 50).background(K.finalColor.cardBlue).cornerRadius(5)
                    } else {
                        HStack {
                            Spacer()
                            Image("poolBuck")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.horizontal, 3)
                            Text("Need PoolBucks")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                                .padding(.leading, 2)
                            Image("poolBuck")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.horizontal, 3)
                            Spacer()
                        }.frame(height: 50).background(K.finalColor.cardBlue).cornerRadius(5)
                    }

                if wagerAmount > 0 && (selectedFriend != nil || whichTab == "public") {
                    Button(action: {
                        viewModel.sendChallenge(senderWagerAmount: Int(wagerAmount), game: game, sendingToPublic: whichTab == "public" ? true : false, sendingToFriends: sendToFriends) {
                            viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {
                                showingSheet = false
                            }
                        }
                    }, label: {
                        HStack {
                            Spacer()
                       
                            Text("Send Challenge")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                .padding(.horizontal)
                            Spacer()
                        }.frame(height: 50).background(K.finalColor.winningGreen).cornerRadius(7.5).padding(.horizontal)
                            .padding(.top)
                    })
           
                }
            }
        }.frame(width: 345)
            .onChange(of: wagerAmount) { newWagerAmount in
                viewModel.senderDirectTicket?.senderWagerAmount = newWagerAmount
            }
        
    }
}

struct searchUserView: View {
    let game: Game
    @ObservedObject var viewModel: peer2peerViewModel
    var betType: BetType
    @Binding var wagerAmount: Double
    
    @State private var opponentUsername: String = ""
    @State private var selectedUserID: String = ""
    @Binding var selectedUser: User?
    
    var body: some View {
        VStack (spacing: 3){
            ZStack {
                VStack {
                    searchBarView(keyword: $opponentUsername)
                        .frame(height: selectedUser == nil ? 44 : 0)
                        .disabled(selectedUser == nil ? false : true)
                        .opacity(selectedUser == nil ? 1 : 0)
                        .onChange(of: opponentUsername) { newUsername in
                            viewModel.fetchUser(from: opponentUsername.lowercased())
                        }
                    
                    ScrollView {
                        VStack {
                            ForEach(viewModel.queriedUsers, id: \.id) { user in
                                if user.id != StaticUserData.shared.currentUser.id {
                                    
                                    userBio(user: user, selectedUserID: $selectedUserID, selectedUserUsername: $opponentUsername, selectedUser: $selectedUser)
                                        .padding(.vertical,3)
                                        .padding(.horizontal,14)
                                }
                            }
                        }
                    }.frame(height: selectedUser == nil ? 50 : 0)
                        .padding(.bottom)
                }
                if selectedUser != nil {
                    VStack {
                        HStack {
                            Text("Selected Opponent")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                                .padding(.leading,3)
                            Spacer()
                            Button(action: {
                                selectedUser = nil
                            }, label: {
                                HStack {
                                    Text("Change")
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                                        .foregroundColor(.white)
                                        .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                                }.background(K.finalColor.potentialOrange).cornerRadius(5)
                            })
                        }
                        HStack {
                            Spacer()
                            if selectedUser?.profileImageUrl != "" {
                                KFImage(URL(string: selectedUser!.profileImageUrl))
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
                            Text("\(selectedUser?.username ?? "")")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(height: 50).background(K.finalColor.cardBlue).cornerRadius(7.5)
                    }.frame(width: 345)
                        .padding(.top)
                    
                    
                }
            }.onChange(of: selectedUser) { _ in
                hideKeyboard()
                viewModel.senderDirectTicket?.receiverID = selectedUser?.id ?? ""
                viewModel.senderDirectTicket?.receiverUsername = selectedUser?.username ?? ""
            }
        }
    }
}

struct twoWagers: View {
    let game: Game
    @ObservedObject var viewModel: peer2peerViewModel
    var betType: BetType
    @Binding var wagerAmount: Double
    
    @State private var opponentUsername: String = ""
    @State private var selectedUserID: String = ""
    @Binding var selectedFriend: Friend?
    
    var body: some View {
            VStack  (spacing: 3){
                HStack {
                    Text("Your Wager")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                        .padding(.leading, 2)
                    Spacer()
                }.frame(width: 345)
                
                VStack(spacing: 7.5) {
                    HStack(spacing: 7.5) {
                        teamMiniView(teamString: returnTeamString(game: game, betType: betType), challengeSender: true)
                        spreadMiniView(betType: betType, spreadString: returnSpreadString(game: game, betType: betType))
                        oddsMiniView(MLString: returnMLString(game: game, betType: betType))
                        
                    }.frame(width: 345)
                    HStack(spacing: 7.5) {
                        riskMiniStruct(game: game, betType: betType, challengeSender: true, challengerOdds: returnOddsFromBetType(betType: betType, game: game),
                                       receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game), wagerAmount: $wagerAmount) // dont need here since you are one sending
                        rewardMiniStruct(
                            game: game,
                            betType: betType,
                            challengeSender: true,
                            challengerOdds: returnOddsFromBetType(betType: betType, game: game),
                            receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game),
                            wagerAmount: $wagerAmount) // dont need here since you are one sending)
                    }.frame(width: 345)
                }
            }
            
            VStack (spacing: 3){
                HStack {
                    Spacer()
                    Text("Opponent Wager")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                        .padding(.trailing, 2)
                }.frame(width: 345)
                
                VStack(spacing: 7.5) {
                    HStack(spacing: 7.5) {
                        oddsMiniView(
                            MLString: returnMLString(game: game, betType: returnOppBetType(betType: betType))
                        )
                        
                        
                        spreadMiniView(
                            betType: returnOppBetType(betType: betType),
                            spreadString: returnSpreadString(game: game, betType: returnOppBetType(betType: betType))
                        )
                        
                        teamMiniView(
                            teamString: returnTeamString(game: game, betType: returnOppBetType(betType: betType)), challengeSender: false
                        )
                    }.frame(width: 345)
                    HStack(spacing: 7.5) {
                        riskMiniStruct(
                            game: game,
                            betType: betType,
                            challengeSender: false,
                            challengerOdds: returnOddsFromBetType(betType: betType, game: game),
                            receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game),
                            wagerAmount: $wagerAmount) // dont need here since you are one sending
                        
                        rewardMiniStruct(
                            game: game,
                            betType: betType,
                            challengeSender: false,
                            challengerOdds: returnOddsFromBetType(betType: betType, game: game),
                            receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game),
                            wagerAmount: $wagerAmount) // dont need here since you are one sending)
                        
                        
                    }.frame(width: 345)
                }
            }.padding(.top, 7.5)
        
        
    }
}

struct teamMiniView: View {
    let teamString: String
    let challengeSender: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("\(teamString)")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: teamString.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()

            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 200).cornerRadius(5)
    }
}

struct spreadMiniView: View {
    let betType: BetType
    let spreadString: String
 
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(spreadString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: spreadString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.cornerRadius(5)
    }
}

struct oddsMiniView: View {
    let MLString: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(MLString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: MLString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.cornerRadius(5)

    }
}


struct riskMiniStruct: View {
    let game: Game
    let betType: BetType
    let challengeSender: Bool
    let challengerOdds: Int
    let receiverOdds: Int
    @Binding var wagerAmount: Double
    var opponentWagerAmount: Double {
        return returnOpponentWagerAmount(wagerAmount: wagerAmount, odds1: challengerOdds, odds2: receiverOdds, betType: betType, game: game)
    }

    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
    
                Text(challengeSender ? "Your Risk" : "Opponent Risk")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.deleteRed)
            HStack (spacing: 3){
                Spacer()
                Image("poolBuck")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(String(format: "%.2f", challengeSender ? wagerAmount : opponentWagerAmount))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}
struct rewardMiniStruct: View {
    let game: Game
    let betType: BetType
    let challengeSender: Bool
    let challengerOdds: Int
    let receiverOdds: Int
    @Binding var wagerAmount: Double
    var opponentWagerAmount: Double {
        return returnOpponentWagerAmount(wagerAmount: wagerAmount, odds1: challengerOdds, odds2: receiverOdds, betType: betType, game: game)
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Text(challengeSender ? "Your Reward" : "Opponent Reward")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.potentialOrange)
            HStack (spacing: 3){
                Spacer()
                Image("poolBuck")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(String(format: "%.2f", returnPotentialWinnings(wagerAmount: challengeSender ? wagerAmount : opponentWagerAmount, MLOdds: challengeSender ? challengerOdds : receiverOdds)))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}




