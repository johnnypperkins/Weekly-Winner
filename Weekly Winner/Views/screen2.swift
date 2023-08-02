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
                        },label:  {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding(.leading) // Add padding to the left side of the button
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
                            ForEach(viewModel.NFLgames, id: \.idd) { game in // HARDCODE NCAAF
                                gameRowView(game: game)
                            }.padding(.horizontal)
                        }
                        if viewModel.selectedGameType == "NCAAF" {
                            ForEach(viewModel.NCAAFGames, id: \.idd) { game in // HARDCODE NCAAF
                                gameRowView(game: game)
                            }.padding(.horizontal)
                        }
                        if viewModel.selectedGameType == "Upcoming" {
                            ForEach(viewModel.upcomingGames, id: \.idd) { game in 
                                gameRowView(game: game)
                            }.padding(.horizontal)
                        }
                    }
                }
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
        .background(Color(currentBetType == betType ? .white : .clear))
        .cornerRadius(currentBetType == betType ? 7.5 : 7.5)
        .shadow(color: currentBetType == betType ? K.veryLightBlue : .clear, radius: 3)
        .scaleEffect(currentBetType == betType ? 1.05 : 1.0)
    }
}

struct gameRowView: View {
    let game: Game
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
                        PlaceBetButton(betType: .betHomeSpread, currentBetType: $betType, title: titleStringH) { // home spread
                            betType = .betHomeSpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(betType: .over, currentBetType: $betType, title: "o" + String(format: "%.0f", game.totalOver)) { // over
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
                        PlaceBetButton(betType: .betAwaySpread, currentBetType: $betType, title: titleStringA) {
                            betType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(betType: .under, currentBetType: $betType, title: "u" + String(format: "%.0f", game.totalUnder)) {
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
                Text("\(formatDate.format(date: game.commenceTime.dateValue()))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(maxWidth: .infinity, alignment: .center)
                //Spacer().frame(height: -5) // Adjust this value to move the Text view up
            }
            
            //Spacer()
        }.padding(.horizontal)
            .padding(EdgeInsets(top: 7.5, leading: 0, bottom: 4, trailing: 0))
            //.padding(.top)
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.green, Color.blue]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//        )
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSheet) {
            BetDetailsView(game: game, betType: $betType)
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
    
    func checkTeamTaken() {
        if betNumber < 0 {
            uploadText = "Ticket Full"
        } else {
            if ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) {
                uploadText = "Place Bet"
            } else {
                uploadText = "Team Taken"
            }
        }
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                //K.finalColor.backgroundBlue
                
                VStack {
                    HStack (spacing: 0){
                        ZStack {
                            VStack {
                                
                            }
                        }
                        ZStack(alignment: .topLeading) {
                            if ticketVM.isBetsLoaded {
                                //Spacer()
                                Picker("Group", selection: $groupNumber) {
                                    ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                        Text(viewModel.userTickets[index].groupName).tag(index)
                                            .foregroundColor(K.finalColor.textWhite)
                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    }
                                }
                                .frame(maxWidth: 200, alignment: .center)
                                .pickerStyle(WheelPickerStyle())
                                .onChange(of: groupNumber) { newValue in
                                    ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: newValue) {
                                        if !ticketVM.availableBets(for: newValue).isEmpty {
                                            betNumber = ticketVM.availableBets(for: groupNumber)[0]
                                            
                                        } else {
                                            betNumber = -99
                                        }
                                        checkTeamTaken()
                                    }
                                }
                                .onAppear {
                                    if !ticketVM.availableBets(for: groupNumber).isEmpty {
                                        betNumber = ticketVM.availableBets(for: groupNumber)[0]
                                    } else {
                                        betNumber = -99
                                    }
                                    checkTeamTaken()
                                }
                                .background(K.finalColor.backgroundBlue)
                                VStack {
                                    Text("Group")
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.textWhite)
                                        .frame(maxWidth: 200, alignment: .leading)
                                        .padding(EdgeInsets(top: 70, leading: 15, bottom: 2.5, trailing: 0))
                                        .background(K.finalColor.backgroundBlue)
                                    //                                    .overlay(
                                    //                                            Rectangle()
                                    //                                                .frame(height: 1)
                                    //                                                //.padding(.top, 100)
                                    //                                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                    //                                                .foregroundColor(.white), alignment: .bottom)
                                }
                                
                            }
                            
                            
                        }.background(Color.white)
                        ZStack(alignment: .topLeading) {
                            //.background(K.veryLightBlue)
                            if ticketVM.isBetsLoaded {
                                Picker("Bet Type", selection: $betNumber) { // starts at 1 bc "1 leg"
                                    if betNumber >= 0 {
                                        ForEach(ticketVM.availableBets(for: groupNumber), id: \.self) { index in //
                                            switch index {
                                            case 1: Text("Straight #1").tag(1)
                                            case 2: Text("Straight #2").tag(2)
                                            case 3: Text("Straight #3").tag(3)
                                            case 4: Text("Straight #4").tag(4)
                                            case 5: Text("2leg #1").tag(5)
                                            case 6: Text("2leg #2").tag(6)
                                            case 7: Text("3leg").tag(7)
                                            case 8: Text("5leg").tag(8)
                                            default: EmptyView()
                                            }
                                        }.foregroundColor(K.finalColor.textWhite)
                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    } else {
                                        Text("FULL")
                                            .foregroundColor(K.finalColor.textWhite)
                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    }
                                }
                                .frame(maxWidth: 200, alignment: .center)
                                .pickerStyle(WheelPickerStyle())
                                .onChange(of: betNumber) { newValue in
                                    print("Selection changed to: \(newValue)")
                                    checkTeamTaken()
                                    if newValue == 8 {
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
                                }
                                .onAppear {
                                    print("\(betNumber) is original betNumber")
                                }
                                
                                VStack {
                                    Text("Bet")
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.textWhite)
                                        .frame(maxWidth: 200, alignment: .leading)
                                        .padding(EdgeInsets(top: 70, leading: 15, bottom: 0, trailing: 0))
                                        .background(K.finalColor.backgroundBlue)
                                }
                                ZStack {
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
                                    
                                    
                                }
                                //                                HStack {
                                //                                    Spacer()
                                //                                    Text("Bet Details")
                                //                                        .foregroundColor(K.finalColor.textWhite)
                                //                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                //                                    Spacer()
                                //                                }
                            }
                        }
                        
                    }.cornerRadius(10)
                    
                    if betType == .betAwaySpread {
                        BetSliderView(teamName: game.awayTeam, originalSpread: game.awaySpread, betNumber: $betNumber, betType: .betAwaySpread, chosenSpread: $chosenSpread)
                    }
                    if betType == .betHomeSpread {
                        BetSliderView(teamName: game.homeTeam, originalSpread: game.homeSpread, betNumber: $betNumber, betType: .betHomeSpread, chosenSpread: $chosenSpread)
                    }
                    if betType == .over {
                        BetSliderView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, betNumber: $betNumber, betType: .over, chosenSpread: $chosenSpread)
                    }
                    if betType == .under {
                        BetSliderView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, betNumber: $betNumber, betType: .under, chosenSpread: $chosenSpread)
                    }
                }
                .onAppear {
                    ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber) {
                        if !ticketVM.availableBets(for: groupNumber).isEmpty {
                            betNumber = ticketVM.availableBets(for: groupNumber)[0]
                        } else {
                            betNumber = -99
                        }
                        checkTeamTaken()
                    }
                    print("Group Number: \(groupNumber), Bet Number: \(betNumber)")
                } // whole thing
                //.background(K.veryLightGray)
                //.cornerRadius(10)
                //.padding()
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
                
                
                Button(action: {
                    print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
                    viewModel.uploadBet(groupNumber: groupNumber, groupID: groupsVM.userTickets[groupNumber].groupID, betNumber: betNumber, team: whichTeam, betLine: chosenSpread, betOdds: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread)), betType: betType, gameID: game.idd ?? "null") {_ in
                        ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber, completion: {
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
                    //                       .background(
                    //                           LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                    //                       )
                        .background(K.finalColor.titleBlue)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                })
                .disabled(betNumber < 0 || !ticketVM.isTeamAvailable(whichTeam, groupNumber, betType))
                .padding(.horizontal)
                //.padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            }
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
                groupsVM.fetchUserTickets() {}
            })
        }
    }
}


struct BetSliderView: View {
    var teamName: String
    var originalSpread: Double
    @Binding var betNumber: Int
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
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                    .foregroundColor(.white)
                    .frame(width: 100, alignment: .leading)
                    .minimumScaleFactor(0.5)
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
                Slider(value: $chosenSpread, in: betType == .over ? Double(originalSpread - 10)...Double(originalSpread + parlayNumToSpread(parlayNum: betNumber)) : Double(originalSpread - parlayNumToSpread(parlayNum: betNumber))...Double(originalSpread + 10), step: 1)
                    .accentColor(K.finalColor.titleBlue)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                //.background(K.finalColor.cardBlue)
        }.cornerRadius(10)
    }
}




struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}
