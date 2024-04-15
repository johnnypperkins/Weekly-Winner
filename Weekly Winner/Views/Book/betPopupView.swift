//
//  betPopupView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 2/28/24.
//

import Foundation
import SwiftUI
import Firebase
import Pow

// the pop up thing



struct dailyChallengeSubmitView: View {
    let game: Game
    @Binding var betType: BetType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = -99
    @State private var originalSpread: Double = -99
    @ObservedObject var viewModel: bookViewModel
    @State private var groupNumber = 0
    @State private var betNumber = -99
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    @State private var extra = "" // to add the extra detail of +, o, u
    @State private var uploadText = ""
    @State private var placeBetOpacity = 1.0
    @State private var placeBetColor: Color = Color.clear
    @State private var placeholder = 5
    
    @State private var timeFrame = "daily"
    @Binding var showingSheet: Bool
    @State var isFavorited = false
    @State var betUploadedSafeGuard = false
    

    let midnightTimestamp = Timestamp(date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!))
    
    func checkTeamTaken() {
        if timeFrame == "daily" {
            if game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) {
                uploadText = "Game Not Today"
                placeBetOpacity = 0.6
                placeBetColor = K.finalColor.deleteRed.opacity(0.6)
            } else {
                if viewModel.isTeamAvailable(whichTeam, groupNumber, betType, betArray: viewModel.currentUserDailyBets) {
                    uploadText = "Add to Ticket"
                    placeBetOpacity = 1
                    placeBetColor = K.finalColor.winningGreen
                    
                } else {
                    uploadText = "Team Taken"
                    placeBetOpacity = 0.6
                    placeBetColor = K.finalColor.titleBlue.opacity(0.6)
                }
            }
        }
    }
    
    var body: some View {
            
        ZStack {
            VStack {
                
                BetSliderView(game: game, betType: betType, chosenSpread: $chosenSpread)
                
                Button(action: {
                    betUploadedSafeGuard = true

//                    withAnimation {
                        isFavorited.toggle()
//                    }
                    
                    viewModel.uploadBet(
                        groupNumber: groupNumber,
                        groupID: timeFrame == "daily" ? StaticUserData.shared.dailyTicket.groupID : StaticUserData.shared.weeklyTicket.groupID,
                        betNumber: viewModel.currentUserDailyBets.isEmpty ? 1 : viewModel.currentUserDailyBets.count,
                        team: whichTeam,
                        betLine: chosenSpread,
                        betOdds: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType)),
                        betType: betType,
                        gameID: game.idd!,
                        whichSport: game.whichSport,
                        points_bought: Int(chosenSpread-originalSpread),
                        timeFrame: timeFrame)
                    
                    { _ in
                        viewModel.fetchBets(uid: Auth.auth().currentUser!.uid, currentWeek: true, selectedWeek: "")
                        {
                            let groupServe = GroupService()
                            groupServe.setPotentialToWin(potential: Int(returnPotentialFromAllStraights(bets: viewModel.currentUserDailyBets)), groupNumber: groupNumber, timeFrame: timeFrame, completion: {_ in })
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        withAnimation {
                            showingSheet = false
                            betType = .None
                        }
                    }

                    
                }, label: {
                    if isFavorited {
                        HStack {
                            
                            Text(uploadText)
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                .padding(.horizontal)
                            
                        }.frame(height: 50).background(placeBetColor).cornerRadius(7.5)
                            .padding(.bottom, 20)
                            .transition(
                                .movingParts.pop(.green)
                            )
                    }
                    else {
                        HStack {
                            Text(uploadText)
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                .padding(.horizontal)
                            
                        }.frame(height: 50).background(placeBetColor).cornerRadius(7.5)
                            .padding(.bottom, 20)
                            .transition(.identity)
                    }
                }).changeEffect(
                    .spray(origin: UnitPoint(x: 0.25, y: 0.5)) {
                      Image("poolBuck")
                            .resizable()
                            .frame(width: 30, height: 30)

                    }, value: isFavorited)
                .disabled(betUploadedSafeGuard || !viewModel.isTeamAvailable(whichTeam, groupNumber, betType, betArray: viewModel.currentUserDailyBets) || (game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) && timeFrame == "daily"))
                .padding(.horizontal)
                Spacer()

                
                
                
            }
            
        }.onAppear(perform: {
            viewModel.fetchBets(uid: Auth.auth().currentUser!.uid, currentWeek: true, selectedWeek: "") {
                checkTeamTaken()
            }
            
            if betType == .betAwaySpread {
                chosenSpread = game.awaySpread
                originalSpread = game.awaySpread
                whichTeam = game.awayTeam
            }
            if betType == .betHomeSpread {
                chosenSpread = game.homeSpread
                originalSpread = game.homeSpread
                whichTeam = game.homeTeam
            }
            if betType == .over {
                chosenSpread = game.totalOver
                originalSpread = game.totalOver
                whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
            }
            if betType == .under {
                chosenSpread = game.totalUnder
                originalSpread = game.totalUnder
                whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
            }
            if betType == .betHomeML {
                chosenSpread = 0
                originalSpread = 0
                whichTeam = game.homeTeam
            }
            if betType == .betAwayML {
                chosenSpread = 0
                originalSpread = 0
                whichTeam = game.awayTeam
            }
        })
    }
}



struct BetSliderView: View {
    let game: Game

    var betType: BetType
    @Binding var chosenSpread: Double
    
    var body: some View {
        VStack (spacing: 7.5){
            HStack(spacing: 7.5) {
                teamMiniView(teamString: returnTeamString(game: game, betType: betType), challengeSender: true)
                spreadMiniView(betType: betType, spreadString: returnSpreadString(game: game, betType: betType))
                oddsMiniView(MLString: returnMLString(game: game, betType: betType))
            }.frame(width: 345)
            HStack(spacing: 7.5) {
                VStack (spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Risk")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(height: 15).background(K.finalColor.deleteRed)
                    HStack {
                        Spacer()
                        Text("100")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(height: 41.25).background(K.finalColor.cardBlue)
                }.cornerRadius(7.5)
                
                VStack (spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Potential Win")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(height: 15).background(K.finalColor.potentialOrange)
                    HStack {
                        Spacer()
                        Text("" + percentageToTotalWin(percentage: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))))
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(height: 41.25).background(K.finalColor.cardBlue)
                }.cornerRadius(7.5)
            }.frame(width: 345)

         
        }
    }
}




