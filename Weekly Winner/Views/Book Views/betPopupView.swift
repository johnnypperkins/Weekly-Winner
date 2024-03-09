//
//  betPopupView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 2/28/24.
//

import Foundation
import SwiftUI
import Firebase

// the pop up thing



struct dailyChallengeSubmitView: View {
    let game: Game
    @Binding var betType: BetType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = -99
    @State private var originalSpread: Double = -99
    @ObservedObject var viewModel: bookViewModel
    @StateObject var ticketVM = ticketViewModel()
    
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
    

    let midnightTimestamp = Timestamp(date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!))
    
    func checkTeamTaken() {
        if timeFrame == "daily" {
            if betNumber < 0 {
                uploadText = "Ticket Complete"
                placeBetOpacity = 0.6
                placeBetColor = K.finalColor.titleBlue.opacity(0.6)
            } else {
                if game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) {
                    uploadText = "Not Today"
                    placeBetOpacity = 0.6
                    placeBetColor = K.finalColor.deleteRed.opacity(0.6)
                } else {
                    if ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) {
                        uploadText = "Place Bet"
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
        
    }
    
    var body: some View {
            
        ZStack {
//            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])
            
            VStack {

                BetSliderView(game: game, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: betType, chosenSpread: $chosenSpread)
                
                chooseWagerBetDetailsView(
                    viewModel: viewModel,
                    ticketVM: ticketVM,
                    timeFrame: $timeFrame,
                    betNumber: $betNumber,
                    chosenSpread: $chosenSpread,
                    betType: $betType,
                    game: game,
                    checkTeamTaken: checkTeamTaken)
                Spacer()
                Button(action: {
                    viewModel.uploadBet(
                        groupNumber: groupNumber,
                        groupID: timeFrame == "daily" ? StaticUserData.shared.dailyTicket.groupID : StaticUserData.shared.weeklyTicket.groupID,
                        betNumber: betNumber,
                        team: whichTeam,
                        betLine: chosenSpread,
                        betOdds: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType)),
                        betType: betType,
                        gameID: game.idd,
                        whichSport: game.whichSport,
                        points_bought: Int(chosenSpread-originalSpread),
                        timeFrame: timeFrame)
                    
                    { _ in
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: groupNumber, ticketFormat: ticketVM.currentTicketFormat, timeFrame: timeFrame) {
                            let groupServe = groupService()
                            groupServe.setPotentialToWin(potential: Int(ticketVM.totalPotentialWon), groupNumber: groupNumber, timeFrame: timeFrame, completion: {_ in })
                            ticketVM.fetchUserTickets(timeFrame: timeFrame) {}
                        }
                    }
                    withAnimation {
                        showingSheet = false
                        betType = .None
                    }
                    
                }, label: {
                    HStack {
                        
                        Text(uploadText)
                            .foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                            .padding(.horizontal)
                        
                    }.frame(height: 50).background(placeBetColor).cornerRadius(7.5)
                        .padding(.bottom, 20)

                 
                })
                .disabled(betNumber < 0 || !ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) || (game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) && timeFrame == "daily"))
                .padding(.horizontal)
                
                
                
            }
            
        }.onAppear(perform: {
            ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid,
                               for: groupNumber,
                               ticketFormat: timeFrame == "daily" ? StaticUserData.shared.dailyTicket.ticketFormat : StaticUserData.shared.dailyTicket.ticketFormat,
                               timeFrame: timeFrame) {
                if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                    betNumber = firstNumberGreaterThanZero
                } else {
                    betNumber = -99
                }
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
    var parlaySize: Int

    var betType: BetType
    @Binding var chosenSpread: Double
    
    var body: some View {
        
        HStack(spacing: 7.5) {
            teamMiniView(teamString: returnTeamString(game: game, betType: betType), challengeSender: true)
            spreadMiniView(betType: betType, spreadString: returnSpreadString(game: game, betType: betType))
            oddsMiniView(MLString: returnMLString(game: game, betType: betType))
        }.frame(width: 345)
        
    }
}

struct chooseWagerBetDetailsView: View {
    @ObservedObject var viewModel: bookViewModel
    @ObservedObject var ticketVM: ticketViewModel
    @Binding var timeFrame: String
    @Binding var betNumber: Int
    @Binding var chosenSpread: Double
    @Binding var betType: BetType
    let game: Game

    var checkTeamTaken: () -> Void
    
    var body: some View {
   
        HStack (spacing: 7.5){
            VStack (spacing: 0) {
                HStack {
                    Spacer()
                    Text("Selected Wager")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    Spacer()
                }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
                
                ScrollView {
                    if betNumber >= 0 {
                        ForEach(0..<1, id: \.self) { _ in
                            //var parlayIndex = 1
                            let availableBets = ticketVM.availableBetsArray
                            let ticketFormat = ticketVM.currentTicketFormat
                            VStack {
                                ForEach(0..<availableBets.count, id: \.self) { index in
                                    if availableBets[index] > 0 {
                                        Button(action: {
                                            betNumber = index + 1
                                            print("Selection changed to: \(index+1)")
                                            checkTeamTaken()
                                            if betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 {
                                                if ticketVM.currentTicketFormat[index] == 5 {
                                                    if betType == .betAwaySpread {
                                                        chosenSpread = game.awaySpread + 1
                                                    }
                                                    if betType == .betHomeSpread {
                                                        chosenSpread = game.homeSpread + 1
                                                    }
                                                    if betType == .over {
                                                        chosenSpread = game.totalOver - 1
                                                    }
                                                    if betType == .under {
                                                        chosenSpread = game.totalUnder + 1
                                                    }
                                                }
                                            } else {
                                                if betType == .betAwaySpread {
                                                    chosenSpread = game.awaySpread
                                                }
                                                if betType == .betHomeSpread {
                                                    chosenSpread = game.homeSpread
                                                }
                                                if betType == .over {
                                                    chosenSpread = game.totalOver
                                                }
                                                if betType == .under {
                                                    chosenSpread = game.totalUnder
                                                }
                                            }
                                        }, label: {
                                            HStack {
                                                Text(parlayTitle(ticketFormat: ticketFormat, index: index)).tag(index+1)
                                                    .foregroundColor(K.finalColor.textWhite)
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                            }.frame(width: 170, height: 30)
                                                //.padding(.top, 5)
                                                .background(betNumber == index+1 ? K.finalColor.titleBlue : K.veryLightGray.opacity(0.4))
                                                .cornerRadius(5)
                                        })
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                }.padding(.vertical, 7.5)
                
            }.frame(width: 200, height: 120)
                //.padding(.horizontal)
                .onAppear {
                    if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                        betNumber = firstNumberGreaterThanZero
                    } else {
                        betNumber = -99
                    }
                    checkTeamTaken()
                }
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
            
            VStack(spacing: 7.5) {
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
                        Text("$100")
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
                        Text("$" + percentageToTotalWin(percentage: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))))
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(height: 41.25).background(K.finalColor.cardBlue)
                }.cornerRadius(7.5)
                
            }.frame(width: 137.5).cornerRadius(5)
        }
            
    }
}


