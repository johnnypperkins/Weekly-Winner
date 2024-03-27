//
//  acceptDirectChallenge.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 3/15/24.
//

import Foundation
import SwiftUI
import Kingfisher
import Firebase

struct acceptDirectChallenge: View {
    
    @ObservedObject var viewModel: challengeViewModel
    let directChallengeTicket: DirectChallengeTicket
    @State var opponentProfileImageURL: String? = nil
    let inAction: Bool
    let publicViewing: Bool
    
    
    var youAreSender: Bool {
        if publicViewing {
            return false 
        } else {
            if directChallengeTicket.senderID == StaticUserData.shared.currentUser.id { // sender id is same as yours
                return true
            } else {
                return false
            }
        }
    }
    
    var challengeResult: String {
        if directChallengeTicket.status == "win" {
            return "win"
        } else if directChallengeTicket.status == "loss" {
            return "loss"
        } else if directChallengeTicket.status == "push" {
            return "push"
        } else {
            return ""
        }
    }
    
    var opponentChallengeResult: String {
        if directChallengeTicket.status == "win" {
            return "loss"
        } else if directChallengeTicket.status == "loss" {
            return "win"
        } else if directChallengeTicket.status == "push" {
            return "push"
        } else {
            return ""
        }
    }
    
    @State var shouldNavigate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    VStack {
                        HStack {
                            Text("Opponent")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                                .padding(.leading,3)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            if opponentProfileImageURL != nil {
                                profilePicDisplayView(dimension: 30, picURL: opponentProfileImageURL!)
                            }
                            
                            Text("\(youAreSender ? directChallengeTicket.receiverUsername : directChallengeTicket.senderUsername)")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(height: 50).background(K.finalColor.cardBlue).cornerRadius(7.5)
                    }.frame(width: 345)
                        .padding(.top)
                    
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
                                if let game = viewModel.fetchedGame {
                                    oddsMiniViewAccepted(
                                        Moneyline: !youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds,
                                        challengeResult: opponentChallengeResult) // GOOD
                                    
                                    spreadMiniViewAccepted(
                                        betType: !youAreSender ? directChallengeTicket.senderBetType : directChallengeTicket.receiverBetType,
                                        spread: !youAreSender ? directChallengeTicket.senderBetLine : directChallengeTicket.receiverBetLine, challengeResult: opponentChallengeResult
                                    )
                                    
                                    teamMiniViewAccepted(
                                        teamString: !youAreSender ? directChallengeTicket.senderTeamName : directChallengeTicket.receiverTeamName, challengeSender: !youAreSender, challengeResult: opponentChallengeResult
                                    )
                                }
                                
                            }.frame(width: 345)
                            HStack(spacing: 7.5) {
                                if let game = viewModel.fetchedGame {
                                    riskMiniStructAccepted(
                                        yourWager: false,
                                        odds: !youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds,
                                        wagerAmount: !youAreSender ? directChallengeTicket.senderWagerAmount : directChallengeTicket.receiverWagerAmount)
                                    
                                    rewardMiniStructAccepted(
                                        yourWager: false,
                                        odds: !youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds,
                                        wagerAmount: !youAreSender ? directChallengeTicket.senderWagerAmount : directChallengeTicket.receiverWagerAmount)
                                    
                                }
                            }.frame(width: 345)
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
                        if let game = viewModel.fetchedGame {
                            VStack(spacing: 7.5) {
                                HStack(spacing: 7.5) {
                                    oddsMiniViewAccepted(Moneyline: youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds, challengeResult: challengeResult)
                                    
                                    spreadMiniViewAccepted(
                                        betType: youAreSender ? directChallengeTicket.senderBetType : directChallengeTicket.receiverBetType,
                                        spread: youAreSender ? directChallengeTicket.senderBetLine : directChallengeTicket.receiverBetLine, challengeResult: challengeResult
                                    )
                                    
                                    teamMiniViewAccepted(
                                        teamString: youAreSender ? directChallengeTicket.senderTeamName : directChallengeTicket.receiverTeamName, challengeSender: !youAreSender, challengeResult: challengeResult
                                    )
                                    
                                }.frame(width: 345)
                                HStack(spacing: 7.5) {
                                    riskMiniStructAccepted(
                                        yourWager: true,
                                        odds: youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds,
                                        wagerAmount: youAreSender ? directChallengeTicket.senderWagerAmount : directChallengeTicket.receiverWagerAmount)
                                    
                                    rewardMiniStructAccepted(
                                        yourWager: true,
                                        odds: youAreSender ? directChallengeTicket.senderOdds : directChallengeTicket.receiverOdds,
                                        wagerAmount: youAreSender ? directChallengeTicket.senderWagerAmount : directChallengeTicket.receiverWagerAmount)
                                    
                                }.frame(width: 345)
                            }
                        }
                    }.padding(.top, 7.5)
                        .onAppear() {
                            viewModel.fetchChallengeGames(matchingID: directChallengeTicket.gameIDs[0]) {}
                            viewModel.fetchUserProfilePic(uid: directChallengeTicket.senderID) { }
                        }
                    VStack {
                        
                            
                            Rectangle().foregroundColor(.white).frame(width: 300, height: 1)
//                            Text("Game Details")
//                                .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                                .foregroundColor(.white)
//                                .padding(.leading, 2)
                            
                        
                        if let game = viewModel.fetchedGame {
                            HStack {
                                gameFinalScore(game: game)
                            }.frame(width: 345).background(K.finalColor.cardBlue).cornerRadius(7.5)
                        }
                    }
                    Spacer()
                    
                    if !inAction {
                        if StaticUserData.shared.currentUser.poolBucks >= directChallengeTicket.receiverWagerAmount {
                            Button(action: {
                                print("Button tapped")
                                viewModel.respondToChallenge(
                                    acceptedChallenge: true,
                                    challengeOG: directChallengeTicket,
                                    publicChallenge: publicViewing ? true : false,
                                    receiverBet: [
                                        "groupNumber": 1,
                                        "betNumber": 0,
                                        "betType": directChallengeTicket.receiverBetType.rawValue,
                                        "betLine": returnSpreadFromBetType(betType: directChallengeTicket.receiverBetType, game: viewModel.fetchedGame!),
                                        "betOdds": MLtoPercentage(moneyline: betTypeToOdds(game: viewModel.fetchedGame!, betType: directChallengeTicket.receiverBetType)), // NEEDS TO BE ADJUSTED MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))
                                        "result": "notStarted",
                                        "gameID": directChallengeTicket.gameIDs[0],
                                        "groupID": directChallengeTicket.customID,
                                        "whichSport": viewModel.fetchedGame!.whichSport,
                                        "timestamp": Timestamp(date: Date.now),
                                        "teamBetOn": returnTeamBetOn(betType: directChallengeTicket.receiverBetType, game: viewModel.fetchedGame!), // NEEDS TO BE ADJUSTED
                                        "points_bought": 0,
                                        "timeFrame": ""
                                    ]
                                ) {
                                    viewModel.fetchChallenges {
                                        print("Toggling shouldNavigate")
                                        shouldNavigate.toggle()
                                        viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {}
                                    }
                                }
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text("Accept Challenge")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                                .background(K.finalColor.winningGreen)
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            })
                            .navigationDestination(isPresented: $shouldNavigate) {
                                tabBarView(selection: .challenges)
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Insufficient PoolBucks")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 56, maxHeight: 56)
                            .background(K.finalColor.potentialOrange)
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
           
                    }
                    
                }
            }.padding(.top, 20)
            .onAppear() {
                fetchUserProfilePic(uid: youAreSender ? directChallengeTicket.receiverID : directChallengeTicket.senderID) { (profileImageUrl, error) in
                    if let error = error {
                        print("Error fetching profile image URL: \(error)")
                    } else if let profileImageUrl = profileImageUrl {
                        self.opponentProfileImageURL = profileImageUrl
                    }
                }
            }
        }
    }
}

struct teamMiniViewAccepted: View {
    let teamString: String
    let challengeSender: Bool
    let challengeResult: String
    
    var color: Color {
        if challengeResult == "win" {
            return K.finalColor.winningGreen
        } else if challengeResult == "loss" {
            return K.finalColor.deleteRed
        } else if challengeResult == "push" {
            return K.averageGray
        } else {
            return K.finalColor.cardBlue
        }
    }
    
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
                
            }.frame(height: 50).background(color)
        }.frame(width: 200).cornerRadius(5)
    }
}

func returnSpreadStringStatic(betType: BetType, spread: Double) -> String {
    if spread == 0 {
        return "ML"
    } else {
        if betType == .under {
            if isWholeNumber(spread) {
                return "u\(String(format: "%.0f", spread))"
            } else {
                return "u\(String(format: "%.1f", spread))"
            }
        } else if betType == .over {
            if isWholeNumber(spread) {
                return "o\(String(format: "%.0f", spread))"
            } else {
                return "o\(String(format: "%.1f", spread))"
            }
        } else if spread > 0 {
            if isWholeNumber(spread) {
                return "+\(String(format: "%.0f", spread))"
            } else {
                return "+\(String(format: "%.1f", spread))"
            }
        } else {
            if isWholeNumber(spread) {
                return "\(String(format: "%.0f", spread))"
            } else {
                return "\(String(format: "%.1f", spread))"
            }
        }
    }
}

struct spreadMiniViewAccepted: View {
    let betType: BetType
    let spread: Double
    let challengeResult: String
    
    var spreadString: String {
        if spread == 0 {
            return "ML"
        } else {
            if betType == .under {
                if isWholeNumber(spread) {
                    return "u\(String(format: "%.0f", spread))"
                } else {
                    return "u\(String(format: "%.1f", spread))"
                }
            } else if betType == .over {
                if isWholeNumber(spread) {
                    return "o\(String(format: "%.0f", spread))"
                } else {
                    return "o\(String(format: "%.1f", spread))"
                }
            } else if spread > 0 {
                if isWholeNumber(spread) {
                    return "+\(String(format: "%.0f", spread))"
                } else {
                    return "+\(String(format: "%.1f", spread))"
                }
            } else {
                if isWholeNumber(spread) {
                    return "\(String(format: "%.0f", spread))"
                } else {
                    return "\(String(format: "%.1f", spread))"
                }
            }
        }
    }
    
    var color: Color {
        if challengeResult == "win" {
            return K.finalColor.winningGreen
        } else if challengeResult == "loss" {
            return K.finalColor.deleteRed
        } else if challengeResult == "push" {
            return K.averageGray
        } else {
            return K.finalColor.cardBlue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(spreadString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: spreadString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(color)
        }.cornerRadius(5)
    }
}

struct oddsMiniViewAccepted: View {
    let Moneyline: Int
    let challengeResult: String
    
    var color: Color {
        if challengeResult == "win" {
            return K.finalColor.winningGreen
        } else if challengeResult == "loss" {
            return K.finalColor.deleteRed
        } else if challengeResult == "push" {
            return K.averageGray
        } else {
            return K.finalColor.cardBlue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(Moneyline > 0 ? "+\(Moneyline)" : "\(Moneyline)")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: String(Moneyline).count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(color)
        }.cornerRadius(5)

    }
}

struct riskMiniStructAccepted: View {
    let yourWager: Bool
    let odds: Int
    let wagerAmount: Double
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
    
                Text(yourWager ? "Your Risk" : "Opponent Risk")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.deleteRed)
            HStack (spacing: 3){
                Spacer()
                Image("poolBuck")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(String(format: "%.2f", wagerAmount))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}

struct rewardMiniStructAccepted: View {
    let yourWager: Bool
    let odds: Int
    let wagerAmount: Double
     
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Text(yourWager ? "Your Reward" : "Opponent Reward")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.potentialOrange)
            HStack (spacing: 3){
                Spacer()
                Image("poolBuck")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(String(format: "%.2f", returnPotentialWinnings(wagerAmount: wagerAmount, MLOdds: odds)))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}

struct gameFinalScore: View {
    let game: Game
    var body: some View {
        HStack {
            VStack (spacing: 3){
                HStack {
                    VStack {
                        HStack {
                            Text("\(game.homeTeam)")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            Text("\(game.awayTeam)")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }.frame(width: 220)
                        .padding(.leading)
                    Spacer()
                    VStack {
                        
                        Text((game.status == "completed") ? "\(game.homeTeamScore)" : "")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(.white)
                            .frame(width: 30)
                        Text((game.status == "completed") ? "\(game.awayTeamScore)" : "")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(.white)
                            .frame(width: 30)
                    }.padding(.trailing)
                    
                }
                
                HStack {
                    Spacer()
                    Text("\(game.whichSport) | \(formatDateEMMMDHMM.format(date: game.commenceTime.dateValue()))")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 10))
                        .foregroundColor(K.finalColor.textWhite)
                        
                    Spacer()
                }
            }
            
        }.padding(EdgeInsets(top: 5, leading: 7.5, bottom: 5, trailing: 0))
    }
}
