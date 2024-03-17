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
    @State private var selectedUser: User? = nil
    
    @ObservedObject var viewModel = peer2peerViewModel()


    var body: some View {
        VStack {
            twoWagers(game: game, viewModel: viewModel, betType: betType, wagerAmount: $wagerAmount, selectedUser: $selectedUser)
            peer2peerSlider(wagerAmount: $wagerAmount, selectedUser: $selectedUser, viewModel: viewModel, game: game, showingSheet: $showingSheet)
            Spacer()
        }.onAppear() {
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
                senderWagerAmount: -99, // WILL ADJUST

                receiverUsername: "", // WILL ADJUST
                receiverID: "", // WILL ADJUST
                receiverOdds: returnOddsFromBetType(betType: returnOppBetType(betType: betType), game: game),
                receiverBetType: returnOppBetType(betType: betType),
                receiverWagerAmount: -99, // WILL ADJUST

                dateCreated: Timestamp(date: Date()),
                currencyChosen: "poolBucks",
                status: challengeStatus.pendingAcceptance.rawValue,
                gameIDs: [game.idd!],
                challengeType: "straight1v1"
            ))
        }
    }
}

struct peer2peerSlider: View {
    @Binding var wagerAmount: Double
    @Binding var selectedUser: User?
    @ObservedObject var viewModel: peer2peerViewModel
    let game: Game
    @Binding var showingSheet: Bool

    var body: some View {
        VStack (spacing: 5){
            if selectedUser != nil {
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

                if wagerAmount > 0 && selectedUser != nil{
                    Button(action: {
                        viewModel.sendChallenge(receiverUser: selectedUser!, senderWagerAmount: Int(wagerAmount), game: game) {
                            showingSheet = false
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

struct twoWagers: View {
    let game: Game
    var viewModel: peer2peerViewModel
    var betType: BetType
    @Binding var wagerAmount: Double
    
    @State private var opponentUsername: String = ""
    @State private var selectedUserID: String = ""
    @Binding var selectedUser: User?
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                opponentUsername.lowercased()
            },
            set: {
                opponentUsername = $0.lowercased()
                viewModel.fetchUser(from: opponentUsername.lowercased())
            }
        )
        
        //ScrollView {
        VStack (spacing: 3){
            ZStack {
                VStack {
                    searchBarView(keyword: keywordBinding)
                        .frame(height: selectedUser == nil ? 44 : 0)
                        .disabled(selectedUser == nil ? false : true)
                        .opacity(selectedUser == nil ? 1 : 0)
                    
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
                    }.frame(height: selectedUser == nil ? 70 : 0)
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
//            HStack {
//                Spacer()
//                Text("Team")
//                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                    .foregroundColor(.white)
//                Spacer()
//            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Spacer()
                Text("\(teamString)")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: teamString.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
//                    .padding(challengeSender ? .leading : .trailing)
                
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 200).cornerRadius(5)
    }
}

struct spreadMiniView: View {
    let betType: BetType
    let spreadString: String
 
    
    var body: some View {
        VStack(spacing: 0) {
//            HStack {
//                Spacer()
//                Text(betType == .over || betType == .under ? "Total" : "Spread")
//                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                    .foregroundColor(.white)
//                Spacer()
//            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
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
//            HStack {
//                Spacer()
//                Text("Odds")
//                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                    .foregroundColor(.white)
//                Spacer()
//            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
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
    
                Text(challengeSender ? "Your Risk Amount" : "Opponent Risk Amount")
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




