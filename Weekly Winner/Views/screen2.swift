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
    @State private var searchTerm: String = ""
    
    @State private var rankedCommence = true

    func shouldAppear(search: String, input: String) -> Bool {
        return input.lowercased().contains(search.lowercased())
    }
    
    // Add this computed property to determine which array of games to use
    var gamesToDisplay: [Game] {
        switch viewModel.selectedGameType {
        case "All Games":
            return rankedCommence ? viewModel.allGames : viewModel.allGamesPopular
        case "NFL":
            return rankedCommence ? viewModel.NFLgames : viewModel.NFLgamesPopular
        case "NCAAF":
            return rankedCommence ? viewModel.NCAAFGames : viewModel.NCAAFGamesPopular
        case "NBA":
            return rankedCommence ? viewModel.NBAGames : viewModel.NBAGamesPopular
        case "NCAAB":
            return rankedCommence ? viewModel.NCAABGames : viewModel.NCAABGamesPopular
        default:
            return []
        }
    }


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
                            searchTerm = ""
                            rankedCommence = true
                        }, label: {
                            HStack {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                            .padding(10) // Add padding around the button
                            .background(K.finalColor.cardBlue) // Set the background color
                            .cornerRadius(5) // Optional: Add a corner radius if you want rounded corners
                        }).padding(.leading)

                        Spacer()
                    }
                    
                    Text(viewModel.selectedGameType)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(K.finalColor.textWhite)
                    
                    HStack{
                        Spacer()
                    }.padding(.trailing)
                }.padding(.top, 3)
                HStack {
                    HStack {
                        TextField("Search", text: $searchTerm)
                            .placeholder(when: searchTerm == "", placeholder: {
                                Text("Search for games...").foregroundColor(.gray)
                                    .padding(.leading, 2)
                            })
                            .foregroundColor(.white)
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                            .accentColor(.white)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                        //.padding(.vertical, 5)
                       
                        
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 15))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(7.5)
                    .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 10))
                    
                    Button(action: {
                        searchTerm = ""
                        rankedCommence.toggle()
                    }, label: {
                        HStack {
                            Text("\(rankedCommence ? "Upcoming" : "Popular")")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundStyle(.white)
                        }
                            .frame(width: 80, height: 40)
                            .background(K.finalColor.titleBlue)
                            .cornerRadius(7.5)
                            .padding(.trailing, 14)
                    })
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
                        // Displaying games
                        if !gamesToDisplay.isEmpty {
                            ForEach(gamesToDisplay, id: \.idd) { game in
                                if (shouldAppear(search: searchTerm, input: game.homeTeam) || shouldAppear(search: searchTerm, input: game.awayTeam) || searchTerm == "") {
                                    if game.commenceTime.dateValue() > Date() {
                                        gameRowView(game: game, isDisabled: false, viewModel: viewModel)
                                    }
//                                    else {
//                                        gameRowView(game: game, isDisabled: true).opacity(0.5)
//                                    }
                                }
                            }.padding(.horizontal)
                        } else {
                            Text("No Games Available")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                .foregroundColor(K.finalColor.textWhite)
                                .padding()
                        }
                        
                    }.padding(.bottom,40)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(K.finalColor.backgroundBlue)
            .cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
        }.background(K.finalColor.backgroundBlue)
            .padding(EdgeInsets(top: 80, leading: 0, bottom: 55, trailing: 0))
            .navigationBarHidden(false)
            .onAppear() {
                rankedCommence = true
            }
    }
    
    private var filteredGames: [Game] {
        switch viewModel.selectedGameType {
        case "All Games":
            return viewModel.allGames
        case "NCAAF":
            return viewModel.NCAAFGames
        case "NFL":
            return viewModel.NFLgames
        case "NBA":
            return viewModel.NBAGames
        case "NCAAB":
            return viewModel.NCAABGames
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
    @ObservedObject var viewModel: bookViewModel

    
    var maxHeight = 100
    var maxWidth = 100
    
    var body: some View {
      
        HStack {
            VStack(spacing:2) {
                HStack{
                    Text("\(game.homeTeam)") // team name
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
                HStack {
                    Text("\(game.awayTeam)")
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
                Text("\(game.whichSport) | \(formatDateEMMMDHMM.format(date: game.commenceTime.dateValue()))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 11))
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
            BetDetailsView(game: game, betType: $betType, viewModel: viewModel)
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
//                                                .cornerRadius(5)
                                        }
                                        //.scaleEffect(x: 2)
                                    })
                                    
                                    
                                    
                                }
                                //.padding(.horizontal)
                                .frame(width: 150, height: 120)
                                //.padding(.horizontal)
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
                        //}.background(Color.red)
                        //Spacer()
                            //.background(K.veryLightBlue)
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
                        
                    }.cornerRadius(10)
                    
                    if betType == .betAwaySpread {
                        BetSliderView(whichSport: game.whichSport, teamName: game.awayTeam, originalSpread: game.awaySpread, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .betAwaySpread, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)
                    }
                    if betType == .betHomeSpread {
                        BetSliderView(whichSport: game.whichSport, teamName: game.homeTeam, originalSpread: game.homeSpread, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .betHomeSpread, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
                    if betType == .over {
                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .over, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
                    if betType == .under {
                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, parlaySize: betNumber <= ticketVM.currentTicketFormat.count && betNumber > 0 ? ticketVM.currentTicketFormat[betNumber-1] : 1, betType: .under, chosenSpread: $chosenSpread)
                            //.padding(.horizontal)

                    }
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
                    viewModel.uploadBet(groupNumber: groupNumber, groupID: timeFrame == "daily" ? StaticUserData.shared.dailyTicket.groupID : StaticUserData.shared.weeklyTicket.groupID
                                        , betNumber: betNumber, team: whichTeam, betLine: chosenSpread, betOdds: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread), whichSport: game.whichSport), betType: betType, gameID: game.idd, whichSport: game.whichSport, points_bought: Int(chosenSpread-originalSpread), timeFrame: timeFrame) {_ in
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, for: groupNumber, ticketFormat: ticketVM.currentTicketFormat, timeFrame: timeFrame) {
                            let groupServe = groupService()
                            groupServe.setPotentialToWin(potential: Int(ticketVM.totalPotentialWon), groupNumber: groupNumber, timeFrame: timeFrame, completion: {_ in })
                            ticketVM.fetchUserTickets(timeFrame: timeFrame) {
//                                ticketVM.fetchCurrentRankedTickets(groupID: timeFrame == "daily" ? "GlobalDaily" : "Global", timeFrame: timeFrame) {}
                                
                            }
                            
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
            })
        }
    }
}


struct BetSliderView: View {
    var whichSport: String
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
                Text("\(teamName)")
                    //.font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                    .font(.custom(K.customFonts.lexendDecaLight, size: teamName.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .frame(width: 150, height: 40, alignment: .leading)
                    //.background(.white)
                Spacer()
                Text(chosenSpread == 0 ? "ML" : "\(internalExtra)\(String(format: "%.0f", chosenSpread))")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 60, alignment: .leading)
                Text("\(percentageToML(percentage: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread), whichSport: whichSport)))")
                    .font(.custom(K.customFonts.lexendDecaLight, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            HStack {
                Slider(value: $chosenSpread, in: betType == .over ? Double(originalSpread - 15)...Double(originalSpread + spreadExtension) : Double(originalSpread - spreadExtension)...Double(originalSpread + 15), step: 1)
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
