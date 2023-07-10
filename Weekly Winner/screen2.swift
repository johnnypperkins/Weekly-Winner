//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

//enum GameType: String, CaseIterable, Hashable {
//    case collegeFootball = "College Football"
//    case nfl = "NFL"
//}

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
                //                Picker("", selection: $selectedGameType) {
                //                    ForEach(GameType.allCases, id: \.self) { gameType in
                //                        Text(gameType.rawValue)
                //                    }
                //                }
                //                .pickerStyle(SegmentedPickerStyle())
                //                .foregroundColor(.blue)
                //                .padding(.horizontal)
                HStack {
                    Text("Betting App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowing.toggle()
                        }
                        // Action for right button
                    }) {
                        Image(systemName: "bell")
                            .imageScale(.large)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 7.5) {
                        if viewModel.selectedGameType == "NFL" {
                            ForEach(viewModel.NFLgames, id: \.idd) { game in // HARDCODE NCAAF
                                BetRowView1(game: game)
                            }.padding()
                        }
                        if viewModel.selectedGameType == "NCAAF" {
                            ForEach(viewModel.NCAAFGames, id: \.idd) { game in // HARDCODE NCAAF
                                BetRowView1(game: game)
                            }.padding()
                        }
                        if viewModel.selectedGameType == "Upcoming" {
                            ForEach(viewModel.upcomingGames, id: \.idd) { game in 
                                BetRowView1(game: game)
                            }.padding()
                        }
                    }
                }
            }.cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
            }
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
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

struct BetRowView1: View {
    let game: Game
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betTeamType: BetTeamType = .None
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    
    var maxHeight = 100
    var maxWidth = 100
    
    var body: some View {
      
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Text(game.homeTeam) // team name
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    HStack(spacing: 20) {
                        BetButton(betTeamType: .betHomeSpread, currentBetType: $betTeamType, title: titleStringH) { // home spread
                            betTeamType = .betHomeSpread
                            showingSheet.toggle()
                        }
                        
                        BetButton(betTeamType: .over, currentBetType: $betTeamType, title: "o" + String(format: "%.0f", game.totalOver)) { // over
                            betTeamType = .over
                            showingSheet.toggle()
                        }
                    }
                    
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                HStack {
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 20) {
                        BetButton(betTeamType: .betAwaySpread, currentBetType: $betTeamType, title: titleStringA) {
                            betTeamType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        BetButton(betTeamType: .under, currentBetType: $betTeamType, title: "u" + String(format: "%.0f", game.totalUnder)) {
                            betTeamType = .under
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
            }
            
            Spacer()
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        .padding()
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSheet) {
            BetDetailsView(game: game, betTeamType: $betTeamType)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
    }
}

// the pop up thing
struct BetDetailsView: View {
    let game: Game
    @Binding var betTeamType: BetTeamType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = 2
    @State private var originalSpread: Double = 2
    @State private var betType = 1
    @ObservedObject var viewModel = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    
    @State private var groupNumber = 0
    @State private var betNumber = -99
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    @State private var extra = "" // to add the extra detail of +, o, u
    
    var body: some View {
        VStack {
            HStack{
                Button {
                    withAnimation {
                        dismiss()
                        betTeamType = .None
                    }
                } label: {
                    Image(systemName: "arrow.turn.left.up")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .foregroundColor(.black)
                }
                Spacer()

                
            }.frame(maxWidth:.infinity, alignment: .center)
                .padding(.leading)
            
            HStack {

                if ticketVM.isBetsLoaded {
                    Picker("Group", selection: $groupNumber) {
                        ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                            Text(viewModel.userGroups[index]).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: groupNumber) { newValue in
                        ticketVM.fetchBets(groupNumber: newValue)
                        print("Picker \(newValue)")
                        if !ticketVM.availableBets(for: newValue).isEmpty {
                            betNumber = ticketVM.availableBets(for: groupNumber)[0]
                        } else {
                            betNumber = -99
                        }
                    }
     
                    Picker("Bet Type", selection: $betNumber) { // starts at 1 bc "1 leg"
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
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: betNumber) { newValue in
                        print("Selection changed to: \(newValue)")
                    }
                    .onAppear {
                        print("\(betNumber) is original betNumber")
                        if !ticketVM.availableBets(for: groupNumber).isEmpty {
                            betNumber = ticketVM.availableBets(for: groupNumber)[0]
                        } else {
                            betNumber = -99
                        }
                        
                    }
            
                    
                }
            }.onAppear {
                ticketVM.fetchBets(groupNumber: groupNumber)
                print("Group Number: \(groupNumber), Bet Number: \(betNumber)")
            }

            if betTeamType == .betAwaySpread {
                BetView(teamName: game.awayTeam, originalSpread: game.awaySpread, betType: 1, chosenSpread: $chosenSpread)
            }
            if betTeamType == .betHomeSpread {
                BetView(teamName: game.homeTeam, originalSpread: game.homeSpread, betType: 2, chosenSpread: $chosenSpread)
            }
            if betTeamType == .over {
                BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, betType: 3, chosenSpread: $chosenSpread)
            }
            if betTeamType == .under {
                BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, betType: 4, chosenSpread: $chosenSpread)
            }
        
            
        Button(action: {
            print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
            viewModel.uploadBet(groupNumber: groupNumber, betNumber: betNumber, team: whichTeam, betLine: chosenSpread, betOdds: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread)), betType: .spread)
                withAnimation {
                    dismiss()
                    betTeamType = .None
                }
            
               }, label: {
                   Text(betNumber > 0 ? "Place Bet" : "Ticket Full")
                       .font(.title)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(
                           LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                       )
                       .cornerRadius(10)
                       .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
               })
        .disabled(betNumber < 0)
        }
        
        .onAppear(perform: {
            if betTeamType == .betAwaySpread {
                chosenSpread = game.awaySpread
                originalSpread = game.awaySpread
                whichTeam = game.awayTeam
                betType = 1
            }
            if betTeamType == .betHomeSpread {
                chosenSpread = game.homeSpread
                originalSpread = game.homeSpread
                whichTeam = game.homeTeam
                betType = 2
            }
            if betTeamType == .over {
                chosenSpread = game.totalOver
                originalSpread = game.totalOver
                whichTeam = "\(game.homeTeam) / \(game.awayTeam) o"
                betType = 3
            }
            if betTeamType == .under {
                chosenSpread = game.totalUnder
                originalSpread = game.totalUnder
                whichTeam = "\(game.homeTeam)/\(game.awayTeam) u"
                betType = 4
            }
            //print("view model.usergroups: \(viewModel.userGroups)")
            var index = 0
            for group in viewModel.userGroups {
               groupDict[group] = index
               index += 1
            }
            
        })
    }
    
}



struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}

struct BetView: View {
    var teamName: String
    var originalSpread: Double
    //var extra: String
    var internalExtra: String {
        if chosenSpread < 0 {
                    return ""
                } else {
                    switch betType {
                    case 1:
                        return "+"
                    case 2:
                        return "+"
                    case 3:
                        return "o"
                    case 4:
                        return "u"
                    default:
                        return ""
                    }
                }
    }
    var betType: Int // 1 AS, 2 HS, 3 O, 4 U
    @Binding var chosenSpread: Double

    var body: some View {
        VStack{
            HStack {
                Text("\(teamName) \(internalExtra)\(String(format: "%.0f", chosenSpread))")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            HStack {
                //Text("Spread/total:")
                  //  .font(.headline)
                Slider(value: $chosenSpread, in: Double(originalSpread - 5)...Double(originalSpread + 5), step: 1)
                    .accentColor(Color(.green))
            }
            .padding()
            
            Text("Odds: \(percentageToML(percentage: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread))))") // sample algorithm
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Divider()
        }
    }
}

struct BetButton: View {
    let betTeamType: BetTeamType
    @Binding var currentBetType: BetTeamType
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 35, maxWidth: 35, alignment: .center)
                .foregroundColor(.blue)
                .padding(10)
                .background(Color(currentBetType == betTeamType ? .gray : .white))
                .cornerRadius(currentBetType == betTeamType ? 20 : 10)
                .shadow(color: currentBetType == betTeamType ? .gray : .clear, radius: 5)
                .scaleEffect(currentBetType == betTeamType ? 0.9 : 1.0)
        }
        .frame(width: 50, height: 45)
        .animation(.spring(), value: 4)
    }
}

//
