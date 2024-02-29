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
struct BetDetailsView: View {
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
    

    let midnightTimestamp = Timestamp(date: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!))
    
    func checkTeamTaken() {
        if timeFrame == "daily" {
            if betNumber < 0 {
                uploadText = "Ticket Complete"
                placeBetOpacity = 0.6
                placeBetColor = K.finalColor.titleBlue.opacity(0.6)
            } else {
                if game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) {
                    uploadText = "Not Available for Daily"
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
        } else {
            if betNumber < 0 {
                uploadText = "Ticket Complete"
                placeBetOpacity = 0.6
                placeBetColor = K.finalColor.titleBlue.opacity(0.6)
            } else {
                if ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) {
                    uploadText = "Place Bet"
                    placeBetOpacity = 1
                    placeBetColor = K.finalColor.winningGreen
                    
                } else {
                    uploadText = "Team Taken"
                    placeBetOpacity = 0.6
                    placeBetColor = K.finalColor.deleteRed.opacity(0.6)
                    
                }
            }
        }
        
    }
    
    var body: some View {
            
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                HStack (){
                    Spacer()
                    Button {
                        withAnimation {
                            dismiss()
                            betType = .None
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.white)
                    }.padding([.top, .trailing])
                }
                VStack {
                    HStack (spacing: 20){
           
                        chooseChallengeTypeBetDetailsView(
                            viewModel: viewModel,
                            ticketVM: ticketVM,
                            timeFrame: $timeFrame,
                            betNumber: $betNumber,
                            checkTeamTaken: checkTeamTaken)
                        
                        chooseWagerBetDetailsView(
                            viewModel: viewModel,
                            ticketVM: ticketVM,
                            timeFrame: $timeFrame,
                            betNumber: $betNumber,
                            chosenSpread: $chosenSpread,
                            betType: $betType,
                            game: game, 
                            checkTeamTaken: checkTeamTaken)
                        
                    }.cornerRadius(10)
                    
                    
                        BetSliderView(game: game, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: betType, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)
                    
//                    if betType == .betHomeSpread {
//                        BetSliderView(whichSport: game.whichSport, teamName: game.homeTeam, originalSpread: game.homeSpread, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .betHomeSpread, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
//                    if betType == .over {
//                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .over, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
//                    if betType == .under {
//                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .under, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
                }
                .onAppear {
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
                    print("Group Number: \(groupNumber), Bet Number: \(betNumber)")
                }.padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
                    
                Button(action: {
                    print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
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
                        dismiss()
                        betType = .None
                    }
                    
                }, label: {
                    Text(uploadText)
                        .foregroundColor(.white)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 20.0))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(placeBetColor)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        //f.padding(.horizontal, 25)
                })
                .disabled(betNumber < 0 || !ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) || (game.commenceTime.seconds > (midnightTimestamp.seconds + 86400) && timeFrame == "daily"))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
                
                
                
            }.padding(.horizontal)
            .onAppear(perform: {
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
}


struct BetSliderView: View {
    let game: Game
    var parlaySize: Int
    //var extra: String
    var internalExtra: String {
        if chosenSpread < 0 {
                return ""
            } else {
                switch betType {
                case .betHomeSpread:
                    return "+"
                case .betAwaySpread:
                    return "+"
                case .betHomeML:
                    return "+"
                case .betAwayML:
                    return "+"
                case .over:
                    return "o"
                case .under:
                    return "u"
                default:
                    return ""
                }
            }
    }
    
    var spreadExtension: Double {
        print("Parlay size: ", parlaySize)
        if parlaySize == 1 {
            return 15
        } else if parlaySize == 2 {
            return 4
        } else if parlaySize == 3 {
            return 1
        } else if parlaySize == 4 || parlaySize == 5 {
            return -1
        }
        
        return 10
    }
    var step: Int {
        if betType == .over {
            return -1
        } else {
            return 1
        }
    }
    

    var betType: BetType
    @Binding var chosenSpread: Double
    
    var teamString: String {
        if betType == .betHomeML || betType == .betHomeSpread {
            return "\(game.homeTeam)"
        } else if betType == .betAwayML || betType == .betAwaySpread {
            return "\(game.awayTeam)"
        } else {
            return "\(game.homeTeam)" + "/" + "\(game.homeTeam)"
        }
    }
    
    var MLString: String {
        if betType == .betHomeML {
            return "\(game.homeML)"
        } else if betType == .betAwayML {
            return "\(game.awayML)"
        } else if betType == .betHomeSpread {
            return "\(game.homeSpreadODDS)"
        } else if betType == .betAwaySpread {
            return "\(game.awaySpreadODDS)"
        } else if betType == .over {
            return "\(game.totalOverODDS)"
        } else if betType == .under {
            return "\(game.totalUnderODDS)"
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack (spacing: 0){
            HStack (spacing: 10) {
                Text("Team")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text(betType == .over || betType == .under ? "Total" : "Spread")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 60, alignment: .leading)
                Text("Odds")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            HStack (spacing: 10){
                Text("\(teamString)")
                    //.font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                    .font(.custom(K.customFonts.lexendDecaLight, size: teamString.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .frame(width: 150, height: 40, alignment: .leading)
                    //.background(.white)
                Spacer()
                Text(chosenSpread == 0 ? "ML" : "\(internalExtra)\(String(format: "%.0f", chosenSpread))")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 60, alignment: .leading)
                
                    //Text("\(percentageToML(percentage: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread), whichSport: whichSport)))")
                    Text(MLString)
                        .font(.custom(K.customFonts.lexendDecaLight, size: 18))
                        .foregroundColor(.white)
                        .frame(width: 65, alignment: .trailing)
                
                    
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
//            HStack {
//                if whichSport != "NHL"{
//                    Slider(value: $chosenSpread, in: betType == .over ? Double(originalSpread - 15)...Double(originalSpread + spreadExtension) : Double(originalSpread - spreadExtension)...Double(originalSpread + 15), step: 1)
//                        .accentColor(K.finalColor.titleBlue)
//                }
//            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
        }.cornerRadius(10)
    }
}

struct chooseChallengeTypeBetDetailsView: View {
    @ObservedObject var viewModel: bookViewModel
    @ObservedObject var ticketVM: ticketViewModel
    @Binding var timeFrame: String
    @Binding var betNumber: Int
    var checkTeamTaken: () -> Void

    var body: some View {
        if ticketVM.isBetsLoaded {
            VStack (alignment: .center){
                VStack {
                    Text("Group")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(K.finalColor.textWhite)
                        .frame(width: 150, alignment: .leading)
                        .background(K.finalColor.backgroundBlue)
                }
                VStack(spacing: 0) {
                    Button(action: {
                        timeFrame = "daily"
                        
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: 0, ticketFormat: StaticUserData.shared.dailyTicket.ticketFormat, timeFrame: timeFrame) {
                                if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                                    betNumber = firstNumberGreaterThanZero
                                } else {
                                    betNumber = -99
                                }
                                checkTeamTaken()
                            }
                    }, label: {
                        VStack (alignment: .center, spacing: 0){
                            HStack {
                                Text("Daily")
                                    .foregroundColor(timeFrame == "daily" ? K.finalColor.textWhite : K.finalColor.textWhite.opacity(0.8))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .scaleEffect(timeFrame != "weekly" ? 1.15 : 1.0)

                            }.frame(width: 150, height: 60, alignment: .center)
                            .background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                        }
                    })
                    
                    Button(action: {
                        timeFrame = "weekly"
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: 0, ticketFormat: StaticUserData.shared.weeklyTicket.ticketFormat, timeFrame: timeFrame) {
                                if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                                    betNumber = firstNumberGreaterThanZero
                                } else {
                                    betNumber = -99
                                }
                                checkTeamTaken()
                            }
                    }, label: {
                        VStack (spacing: 0) {
                            HStack {
                                Text("Weekly")
                                    .foregroundColor(timeFrame != "daily" ? K.finalColor.textWhite : K.finalColor.textWhite.opacity(0.8))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .scaleEffect(timeFrame == "weekly" ? 1.15 : 1.0)

                            }.frame(width: 150, height: 60, alignment: .center)
                                .background(timeFrame != "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                        }
                    })
                    
                }
                .frame(width: 150, height: 120)
                .onAppear {
                    if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                        betNumber = firstNumberGreaterThanZero
                    } else {
                        betNumber = -99
                    }
                    checkTeamTaken()
                }
                //.background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
            }
        }
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
        VStack {
            if ticketVM.isBetsLoaded {
                VStack {
                    Text("Bet")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(K.finalColor.textWhite)
                        .frame(width: 150, alignment: .leading)
                    //.padding(EdgeInsets(top: 70, leading: 15, bottom: 0, trailing: 0))
                        .background(K.finalColor.backgroundBlue)
                }
                VStack {
                    
                    ScrollView {
                        if betNumber >= 0 {
                            ForEach(0..<1, id: \.self) { _ in
                                //var parlayIndex = 1
                                let availableBets = ticketVM.availableBetsArray
                                let ticketFormat = ticketVM.currentTicketFormat
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
                                            }.frame(width: 120, height: 30, alignment: .center)
                                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                                .background(betNumber == index+1 ? K.finalColor.titleBlue : K.veryLightGray.opacity(0.4))
                                                .cornerRadius(5)
                                        })
                                    }
                                }
                            }
                            
                        } else {
                            VStack {
                                Spacer()
                                VStack (alignment: .center){
                                    
                                    Text("Ticket")
                                        .foregroundColor(K.finalColor.textWhite)
                                        .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    Text("Complete")
                                        .foregroundColor(K.finalColor.textWhite)
                                        .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    
                                }
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .background(K.finalColor.titleBlue.opacity(0.6))
                                .cornerRadius(5)
                                
                                //.scaleEffect(x: 2)
                                Spacer()
                                
                            }.padding(.top,15)
                        }
                    }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    
                }.frame(width: 120, height: 120)
                    .padding(.horizontal)
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
            }
        }
    }
}


