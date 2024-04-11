//
//  RandomGarbage.swift
//  Weekly Winner
//
//  Created by Reid Brown on 4/10/24.
//

import Foundation
//struct chooseWagerBetDetailsView: View {
//    @ObservedObject var viewModel: bookViewModel
//    @ObservedObject var ticketVM: ticketViewModel
//    @Binding var timeFrame: String
//    @Binding var betNumber: Int
//    @Binding var chosenSpread: Double
//    @Binding var betType: BetType
//    let game: Game
//
//    var checkTeamTaken: () -> Void
//
//    var body: some View {
//
//        HStack (spacing: 7.5){
//            VStack (spacing: 0) {
//                HStack {
//                    Spacer()
//                    Text("Selected Wager")
//                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                        .foregroundColor(.white)
//                    Spacer()
//                }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
//
//                ScrollView {
//                    if betNumber >= 0 {
//                        ForEach(0..<1, id: \.self) { _ in
//                            //var parlayIndex = 1
//                            let availableBets = ticketVM.availableBetsArray
//                            let ticketFormat = ticketVM.currentTicketFormat
//                            VStack {
//                                ForEach(0..<availableBets.count, id: \.self) { index in
//                                    if availableBets[index] > 0 {
//                                        Button(action: {
//                                            betNumber = index + 1
//                                            print("Selection changed to: \(index+1)")
//                                            checkTeamTaken()
//                                            if betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 {
//                                                if ticketVM.currentTicketFormat[index] == 5 {
//                                                    if betType == .betAwaySpread {
//                                                        chosenSpread = game.awaySpread + 1
//                                                    }
//                                                    if betType == .betHomeSpread {
//                                                        chosenSpread = game.homeSpread + 1
//                                                    }
//                                                    if betType == .over {
//                                                        chosenSpread = game.totalOver - 1
//                                                    }
//                                                    if betType == .under {
//                                                        chosenSpread = game.totalUnder + 1
//                                                    }
//                                                }
//                                            } else {
//                                                if betType == .betAwaySpread {
//                                                    chosenSpread = game.awaySpread
//                                                }
//                                                if betType == .betHomeSpread {
//                                                    chosenSpread = game.homeSpread
//                                                }
//                                                if betType == .over {
//                                                    chosenSpread = game.totalOver
//                                                }
//                                                if betType == .under {
//                                                    chosenSpread = game.totalUnder
//                                                }
//                                            }
//                                        }, label: {
//                                            HStack {
//                                                Text(parlayTitle(ticketFormat: ticketFormat, index: index)).tag(index+1)
//                                                    .foregroundColor(K.finalColor.textWhite)
//                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
//                                            }.frame(width: 170, height: 30)
//                                                //.padding(.top, 5)
//                                                .background(betNumber == index+1 ? K.finalColor.titleBlue : K.veryLightGray.opacity(0.4))
//                                                .cornerRadius(5)
//                                        })
//                                    }
//
//                                }
//                            }
//                        }
//
//                    }
//                }.padding(.vertical, 7.5)
//
//            }.frame(width: 200, height: 120)
//                //.padding(.horizontal)
//                .onAppear {
//                    if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
//                        betNumber = firstNumberGreaterThanZero
//                    } else {
//                        betNumber = -99
//                    }
//                    checkTeamTaken()
//                }
//                .background(K.finalColor.cardBlue)
//                .cornerRadius(7.5)
//
//            VStack(spacing: 7.5) {
//                VStack (spacing: 0) {
//                    HStack {
//                        Spacer()
//                        Text("Risk")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                            .foregroundColor(.white)
//                        Spacer()
//                    }.frame(height: 15).background(K.finalColor.deleteRed)
//                    HStack {
//                        Spacer()
//                        Text("100")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
//                            .foregroundColor(.white)
//                        Spacer()
//                    }.frame(height: 41.25).background(K.finalColor.cardBlue)
//                }.cornerRadius(7.5)
//
//                VStack (spacing: 0) {
//                    HStack {
//                        Spacer()
//                        Text("Potential Win")
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                            .foregroundColor(.white)
//                        Spacer()
//                    }.frame(height: 15).background(K.finalColor.potentialOrange)
//                    HStack {
//                        Spacer()
//                        Text("" + percentageToTotalWin(percentage: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))))
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
//                            .foregroundColor(.white)
//                        Spacer()
//                    }.frame(height: 41.25).background(K.finalColor.cardBlue)
//                }.cornerRadius(7.5)
//
//            }.frame(width: 137.5).cornerRadius(5)
//        }
//
//    }
//}
