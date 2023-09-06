//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase

struct BettingAppView: View {
//    @State private var selectedGameType = GameType.nfl
    @StateObject private var viewModel = bookViewModel()
    @State private var showingSheet = false
    @State private var isShowing = false

    var body: some View {
        ZStack{
            if isShowing {
                sideMenuView(bookVM: viewModel, isShowing: $isShowing)
            }
            VStack {

                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation(.spring()) {
                                isShowing.toggle()
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                                    .padding(.leading) // Add padding to the left side of the button
                            }
                            .padding() // Add padding around the button
                            .background(K.finalColor.backgroundBlue) // Set the background color
                            .cornerRadius(10) // Optional: Add a corner radius if you want rounded corners
                        })

                        Spacer()
                    }
                    Text(viewModel.selectedGameType)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(K.finalColor.textWhite)
                }
                
                HStack{
                    Text("Team Name") // team name
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.leading)
                    Spacer()
                    HStack(spacing: 15) {
                        Text("Spr")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(K.finalColor.textWhite)
                            .frame(width: 50, alignment: .center)
                        Text("Tot")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(K.finalColor.textWhite)
                            .frame(width: 50, alignment: .center)
                            .padding(.trailing, 9)
                    }
                    
                    Divider()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
                .padding(.horizontal)
                .overlay(
                        Rectangle()
                            .frame(height: 1)
                            //.padding(.top, 100)
                            .padding(.horizontal)
                            .foregroundColor(.white), alignment: .bottom)
               
                
                ScrollView {
                    VStack(spacing: 5) {
                        if viewModel.selectedGameType == "NFL" {
                            if !viewModel.NFLgames.isEmpty {
                                ForEach(viewModel.NFLgames, id: \.idd) { game in // HARDCODE NCAAF
                                    if game.commenceTime.dateValue() > Date() {
                                        gameRowView(game: game, isDisabled: false)
                                    } else {
                                        gameRowView(game: game, isDisabled: true).opacity(0.5)
                                    }
                                }.padding(.horizontal)
                            } else {
                                Text("No Games Available")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(K.finalColor.textWhite)
                                    .padding()
                                    //.frame(width: 50, alignment: .center)
                            }
                        }
                        if viewModel.selectedGameType == "NCAAF" {
                            if !viewModel.NCAAFGames.isEmpty {
                                ForEach(viewModel.NCAAFGames, id: \.idd) { game in // HARDCODE NCAAF
                                    if game.commenceTime.dateValue() > Date() {
                                        gameRowView(game: game, isDisabled: false)
                                    } else {
                                        gameRowView(game: game, isDisabled: true).opacity(0.5)
                                    }
                                }.padding(.horizontal)
                            } else {
                                Text("No Games Available")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(K.finalColor.textWhite)
                                    .padding()
                            }
                        }
                        if viewModel.selectedGameType == "Upcoming" {
                            if !viewModel.upcomingGames.isEmpty {
                                ForEach(viewModel.upcomingGames, id: \.idd) { game in
                                    if game.commenceTime.dateValue() > Date() {
                                        gameRowView(game: game, isDisabled: true)
                                    }
                                }.padding(.horizontal)
                            } else {
                                Text("No Games Available")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(K.finalColor.textWhite)
                                    .padding()
                            }
                        }
                    }.padding(.bottom,80)
                }.padding(.top,10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(K.finalColor.backgroundBlue)
            .cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
        }.background(K.finalColor.backgroundBlue)
            .padding(.top, 65)
            .navigationBarHidden(false)
    }
    
    private var filteredGames: [Game] {
        switch viewModel.selectedGameType {
        case "Upcoming":
            return viewModel.upcomingGames
        case "NCAAF":
            // return array of college football games from your viewModel
            return viewModel.NCAAFGames
        case "NFL":
            // return array of NFL games from your viewModel
            return viewModel.NFLgames
        default:
            return []
        }
    }
}

struct PlaceBetButton: View {
    let isDisabled: Bool
    let betType: BetType
    @Binding var currentBetType: BetType
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                //.frame(minWidth: 35, maxWidth: 35, alignment: .center)
                .foregroundColor(K.finalColor.titleBlue)
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                
        }
        .frame(width: 50, height: 30)
        .animation(.spring(), value: 4)
        .background(currentBetType == betType ? K.finalColor.textWhite : K.finalColor.cardBlue)
        .overlay(
                RoundedRectangle(cornerRadius: currentBetType == betType ? 7.5 : 7.5)
                    .stroke(currentBetType == betType ? Color.blue : Color.gray, lineWidth: 1.0)
            )
        .cornerRadius(currentBetType == betType ? 7.5 : 7.5)
        .shadow(color: currentBetType == betType ? K.veryLightBlue : .clear, radius: 3)
        .scaleEffect(currentBetType == betType ? 1.05 : 1.0)
        .disabled(isDisabled)
        
        
    }
}

struct gameRowView: View {
    let game: Game
    let isDisabled: Bool
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betType: BetType = .None
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    
    var maxHeight = 100
    var maxWidth = 100
    
    var body: some View {
      
        HStack {
            VStack() {
                HStack{
                    Text(game.homeTeam) // team name
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    HStack(spacing: 15) {
                        PlaceBetButton(isDisabled: isDisabled, betType: .betHomeSpread, currentBetType: $betType, title: titleStringH) { // home spread
                            betType = .betHomeSpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(isDisabled: isDisabled, betType: .over, currentBetType: $betType, title: "o" + String(format: "%.0f", game.totalOver)) { // over
                            betType = .over
                            showingSheet.toggle()
                        }
                    }
                    
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)

                //Divider()
                
                HStack {
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 15) {
                        PlaceBetButton(isDisabled: isDisabled, betType: .betAwaySpread, currentBetType: $betType, title: titleStringA) {
                            betType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(isDisabled: isDisabled, betType: .under, currentBetType: $betType, title: "u" + String(format: "%.0f", game.totalUnder)) {
                            betType = .under
                            showingSheet.toggle()
                        }
                    }
                }.padding(.top,4)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .onAppear {
                        if (game.homeSpread < 0) {
                            titleStringH = String(format: "%.0f", game.homeSpread)
                        } else {
                            titleStringH = "+" + String(format: "%.0f", game.homeSpread)
                        }
                        if (game.awaySpread < 0) {
                            titleStringA = String(format: "%.0f", game.awaySpread)
                        } else {
                            titleStringA = "+" + String(format: "%.0f", game.awaySpread)
                        }
                    }
                Text("\(formatDateMMMDHMM.format(date: game.commenceTime.dateValue()))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }.padding(.horizontal)
            .padding(EdgeInsets(top: 7.5, leading: 0, bottom: 4, trailing: 0))
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSheet) {
            BetDetailsView(game: game, betType: $betType)
                //.padding(.horizontal)
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .background(K.finalColor.backgroundBlue)
            .onDisappear(){
                withAnimation{
                    betType = .None
                }
            }
        }
    }
}

// the pop up thing
struct BetDetailsView: View {
    let game: Game
    @Binding var betType: BetType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = -99
    @State private var originalSpread: Double = -99
    @ObservedObject var viewModel = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    @StateObject var groupsVM = groupsViewModel()
    
    @State private var groupNumber = 0
    @State private var betNumber = -99
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    @State private var extra = "" // to add the extra detail of +, o, u
    @State private var uploadText = ""
    @State private var placeBetOpacity = 1.0
    @State private var placeholder = 5
    
    func checkTeamTaken() {
        if betNumber < 0 {
            uploadText = "Ticket Complete"
            placeBetOpacity = 0.7
        } else {
            if ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) {
                uploadText = "Place Bet"
                placeBetOpacity = 1
            } else {
                uploadText = "Team Taken"
                placeBetOpacity = 0.7
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
                        //ZStack(alignment: .topLeading) {
                        
                        if ticketVM.isBetsLoaded {
                            VStack (alignment: .center){
                                VStack {
                                    Text("Group")
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.textWhite)
                                        .frame(width: 150, alignment: .leading)
                                        //.padding(EdgeInsets(top: 70, leading: 15, bottom: 2.5, trailing: 0))
                                        .background(K.finalColor.backgroundBlue)
                                }
                                VStack {
                                    ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                        Button(action: {
                                            groupNumber = index
                                            ticketVM.fetchUserTickets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber) {
                                                ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: groupNumber, ticketFormat: ticketVM.currentTicketFormat) {
                                                    if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                                                        betNumber = firstNumberGreaterThanZero
                                                    } else {
                                                        betNumber = -99
                                                    }
                                                    checkTeamTaken()
                                                }
                                            }
                                        }, label: {
                                            HStack {
                                                Text(viewModel.userTickets[index].groupName).tag(index)
                                                    .foregroundColor(K.finalColor.textWhite)
                                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                            }.frame(width: 100, alignment: .center)
                                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                                .background(groupNumber == index ? K.finalColor.titleBlue : K.finalColor.tabSelectedBlue)
                                                .cornerRadius(5)
                                            //.scaleEffect(x: 2)
                                        })
                                        
                                    }
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
                        //}.background(Color.red)
                        //Spacer()
                            //.background(K.veryLightBlue)
                        VStack {
                            VStack {
                                Text("Bet")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(K.finalColor.textWhite)
                                    .frame(width: 150, alignment: .leading)
                                    //.padding(EdgeInsets(top: 70, leading: 15, bottom: 0, trailing: 0))
                                    .background(K.finalColor.backgroundBlue)
                            }
                            if ticketVM.isBetsLoaded {
                                VStack {
                                    if viewModel.userTickets.count > 0 {
                                        ScrollView {
                                            //ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                                if betNumber >= 0 {
                                                    ForEach(0..<1, id: \.self) { _ in
                                                        //var parlayIndex = 1
                                                        let availableBets = ticketVM.availableBetsArray
                                                        let ticketFormat = ticketVM.currentTicketFormat
                                                        ForEach(0..<availableBets.count, id: \.self) { index in
                                                            //let index = bet - 1
                                                            //let parlayType = ticketVM.currentTicketFormat[index]
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
                                                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                                                    }.frame(width: 100, alignment: .center)
                                                                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                                                        .background(betNumber == index+1 ? K.finalColor.titleBlue : K.finalColor.tabSelectedBlue)
                                                                        .cornerRadius(5)
                                                                        //.padding(.top, availableBets[index] - 1 == index ? 8 : 0)
                                                                })
                                                            }
                                                        }
                                                    }
                                                    
                                                //}
                                                
                                            } else {
                                                
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
                                                .background(K.finalColor.winningGreen.opacity(0.75))
                                                .cornerRadius(5)

                                                    //.scaleEffect(x: 2)
                                                    Spacer()
                                                
                                            }
                                        }.padding(EdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0))
                                    }
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
                                
//                                Picker("Bet Type", selection: $betNumber) {
//                                    if betNumber >= 0 {
//                                        ForEach(0..<1, id: \.self) { _ in
//                                            //var parlayIndex = 1
//                                            let availableBets = ticketVM.availableBetsArray
//                                            let ticketFormat = ticketVM.currentTicketFormat
//                                            ForEach(0..<availableBets.count, id: \.self) { index in
//                                                //let index = bet - 1
//                                                //let parlayType = ticketVM.currentTicketFormat[index]
//                                                if availableBets[index] > 0 {
//                                                    Text(parlayTitle(ticketFormat: ticketFormat, index: index)).tag(index+1)
//                                                        .foregroundColor(K.finalColor.textWhite)
//                                                        .font(.custom(K.customFonts.lexendDecaLight, size: 16))
//                                                        .scaleEffect(x: 2)
//
//                                                }
//                                            }
//                                        }
//
//                                    } else {
//                                        Text("FULL")
//                                            .foregroundColor(K.finalColor.textWhite)
//                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
//                                            .scaleEffect(x: 2)
//                                    }
//                                }.scaleEffect(x: 0.5)
//                                .frame(width: 150, alignment: .center)
//                                .padding(.horizontal)
//                                .pickerStyle(WheelPickerStyle())
//                                .onChange(of: betNumber) { newValue in
//                                    print("Selection changed to: \(newValue)")
//                                    checkTeamTaken()
//                                    if betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 {
//                                        if ticketVM.currentTicketFormat[newValue-1] == 5 {
//                                            if betType == .betAwaySpread {
//                                                chosenSpread = game.awaySpread + 1
//                                            }
//                                            if betType == .betHomeSpread {
//                                                chosenSpread = game.homeSpread + 1
//                                            }
//                                            if betType == .over {
//                                                chosenSpread = game.totalOver - 1
//                                            }
//                                            if betType == .under {
//                                                chosenSpread = game.totalUnder + 1
//                                            }
//                                        }
//                                    } else {
//                                        if betType == .betAwaySpread {
//                                            chosenSpread = game.awaySpread
//                                        }
//                                        if betType == .betHomeSpread {
//                                            chosenSpread = game.homeSpread
//                                        }
//                                        if betType == .over {
//                                            chosenSpread = game.totalOver
//                                        }
//                                        if betType == .under {
//                                            chosenSpread = game.totalUnder
//                                        }
//                                    }
//                                }
//                                .onAppear {
//                                    print("\(betNumber) is original betNumber")
//                                }
//
                                

                            }
                        
                    }.cornerRadius(10)
                    
                    if betType == .betAwaySpread {
                        BetSliderView(teamName: game.awayTeam, originalSpread: game.awaySpread, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .betAwaySpread, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)
                    }
                    if betType == .betHomeSpread {
                        BetSliderView(teamName: game.homeTeam, originalSpread: game.homeSpread, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .betHomeSpread, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
                    if betType == .over {
                        BetSliderView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .over, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
                    if betType == .under {
                        BetSliderView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .under, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
                }
                .onAppear {
                    ticketVM.fetchUserTickets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber) {
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: groupNumber, ticketFormat: ticketVM.currentTicketFormat) {
                            if let firstNumberGreaterThanZero = ticketVM.availableBetsArray.first(where: { $0 > 0 }) {
                                betNumber = firstNumberGreaterThanZero
                            } else {
                                betNumber = -99
                            }
                            checkTeamTaken()
                        }
                    }
                    print("Group Number: \(groupNumber), Bet Number: \(betNumber)")
                }.padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
                    
                Button(action: {
                    print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
                    viewModel.uploadBet(groupNumber: groupNumber, groupID: groupsVM.userTickets[groupNumber].groupID, betNumber: betNumber, team: whichTeam, betLine: chosenSpread, betOdds: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread)), betType: betType, gameID: game.idd ?? "null") {_ in
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: groupNumber, ticketFormat: ticketVM.currentTicketFormat, completion: {
                            let groupServe = groupService()
                            groupServe.setPotentialToWin(potential: Int(ticketVM.totalPotentialWon), groupNumber: groupNumber, completion: {_ in })
                        })
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
                        .background(K.finalColor.titleBlue.opacity(placeBetOpacity))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        //f.padding(.horizontal, 25)
                })
                .disabled(betNumber < 0 || !ticketVM.isTeamAvailable(whichTeam, groupNumber, betType))
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
            })
        }
    }
}


struct BetSliderView: View {
    var teamName: String
    var originalSpread: Double
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
            return 10
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
    
    var body: some View {
        VStack (spacing: 0){
            HStack (spacing: 10) {
                Text("Team")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text(betType == .over || betType == .under ? "Total" : "Spread")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 55, alignment: .leading)
                Text("Odds")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                    .foregroundColor(.white)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            HStack (spacing: 10){
                Text("\(teamName)")
                    //.font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                    .font(.custom(K.customFonts.lexendDecaMedium, size: teamName.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .frame(width: 150, height: 40, alignment: .leading)
                    //.background(.white)
                Spacer()
                Text("\(internalExtra)\(String(format: "%.0f", chosenSpread))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 55, alignment: .leading)
                Text("\(percentageToML(percentage: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread))))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            HStack {
                Slider(value: $chosenSpread, in: betType == .over ? Double(originalSpread - 10)...Double(originalSpread + spreadExtension) : Double(originalSpread - spreadExtension)...Double(originalSpread + 10), step: 1)
                    .accentColor(K.finalColor.titleBlue)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
        }.cornerRadius(10)
    }
}

struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}
