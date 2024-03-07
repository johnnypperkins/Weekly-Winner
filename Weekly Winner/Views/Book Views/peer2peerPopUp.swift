//
//  peer2peerPopUp.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 3/4/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct peer2peerSubmitPage: View {
    let game: Game
    let betType: BetType
    let viewModel: bookViewModel
    @State var wagerAmount = 0.0
    @State private var selectedUser: User? = nil

    var body: some View {
        
            VStack {
                twoWagers(game: game, parlaySize: 1, viewModel: viewModel, betType: betType, wagerAmount: $wagerAmount, selectedUser: $selectedUser)
                peer2peerSlider(wagerAmount: $wagerAmount, selectedUser: $selectedUser)
                Spacer()
            }
        
    }
}

struct peer2peerSlider: View {
    @Binding var wagerAmount: Double
    @Binding var selectedUser: User?

    var body: some View {
        VStack (spacing: 5){
            HStack {
                Text("Wager Amount")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                    .padding(.leading, 2)
                Spacer()
            }.padding(.top)
            if StaticUserData.shared.currentUser.poolBucks != 0 {
                HStack {
                    Text("0")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    Slider(value: $wagerAmount, in: 0.0...min(StaticUserData.shared.currentUser.poolBucks, 100), step: 1) { editing in
                        
                    }.accentColor(.white)
                        .padding()
                    
                    Text("\(String(format: "%.0f", min(StaticUserData.shared.currentUser.poolBucks, 100)))")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                        .padding(.trailing)
                }.frame(height: 50).background(K.finalColor.cardBlue).cornerRadius(5)
            }
            if wagerAmount > 0 && selectedUser != nil{
                HStack {
                    Spacer()
                    Text("Send Challenge")
                        .foregroundColor(.white)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                        .padding(.horizontal)
                    Spacer()
                }.frame(height: 50).background(K.finalColor.winningGreen).cornerRadius(7.5).padding(.horizontal)
                    .padding(.top)
            }
      
        }.frame(width: 345)
        

        
    }
}

struct twoWagers: View {
    let game: Game
    var parlaySize: Int
    var viewModel: bookViewModel
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
                        }.frame(height: selectedUser == nil ? 115 : 0)
                            .padding(.vertical)
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
                }
                
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
                        
                    }
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
                    }
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
        //}/*.frame(height: 800)*/
        
    }
}

struct teamMiniView: View {
    let teamString: String
    let challengeSender: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Team")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
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
            HStack {
                Spacer()
                Text(betType == .over || betType == .under ? "Total" : "Spread")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Spacer()
                Text(spreadString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: spreadString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 65).cornerRadius(5)
    }
}

struct oddsMiniView: View {
    let MLString: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Odds")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Spacer()
                Text(MLString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: MLString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 65).cornerRadius(5)

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


func returnOpponentWagerAmount(wagerAmount: Double, odds1: Int, odds2: Int, betType: BetType, game: Game) -> Double {
    if odds1 >= -110 && odds1 <= -100 && odds2 >= -110 && odds2 <= -100 { // if -107/-103 or -105, -105, then just keep it simple and make users have same amount to potentially win
        return wagerAmount
    } else { // if something like -170 and +200, then make the potential winnings of the challenging users bets that that the wager that the receiving user must make
        // -116, +105 --> 29 to win 25, 25 to win 26ish
        return returnPotentialWinnings(wagerAmount: wagerAmount, MLOdds: odds1)
    }
}

func returnOddsFromBetType(betType: BetType, game: Game) -> Int {
    switch betType {
    case .betHomeSpread:
        return game.homeSpreadODDS
    case .betAwaySpread:
        return game.awaySpreadODDS
    case .over:
        return game.totalOverODDS
    case .under:
        return game.totalUnderODDS
    case .betHomeML:
        return game.homeML
    case .betAwayML:
        return game.awayML
    case .None:
        return -99
    }
}

func returnPotentialWinnings(wagerAmount: Double, MLOdds: Int) -> Double {
    if MLOdds > 0 {
        return wagerAmount*Double(MLOdds)/100
    } else {
        return wagerAmount*(100/((-1)*Double(MLOdds)))
    }
}


