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
    let betType: BetType
    @Binding var wagerAmount: Double
    @ObservedObject var viewModel: challengeViewModel
    let directChallengeTicket: DirectChallengeTicket
    var senderProfileImageUrl: String? = nil
    let inAction: Bool
    
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
                            if viewModel.opponentProfilePicURL != "" {
                                KFImage(URL(string: viewModel.opponentProfilePicURL))
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
                            Text("\(directChallengeTicket.senderUsername)")
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
                                
                            }.frame(width: 345)
                            HStack(spacing: 7.5) {
                                if let game = viewModel.fetchedGame {
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
                                Spacer()
                                Text("\(viewModel.fetchedGame!.whichSport) | \(formatDateEMMMDHMM.format(date: viewModel.fetchedGame!.commenceTime.dateValue()))")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 11))
                                    .foregroundColor(K.finalColor.textWhite)
                                Spacer()
                            }.frame(width: 345, height: 40).background(K.finalColor.cardBlue).cornerRadius(7.5)

                               
                        }
                    }
                    Spacer()
                    
                    if !inAction {
                        if StaticUserData.shared.currentUser.poolBucks >= directChallengeTicket.receiverWagerAmount {
                            Button(action: {
                                print("Button tapped")
                                viewModel.respondToChallenge(
                                    acceptedChallenge: true,
                                    challenge: directChallengeTicket,
                                    receiverBet: [
                                        "groupNumber": 1,
                                        "betNumber": 0,
                                        "betType": directChallengeTicket.receiverBetType.rawValue,
                                        "betLine": returnSpreadFromBetType(betType: betType, game: viewModel.fetchedGame!),
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
   
        }
    }
}
