//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

enum GameType: String, CaseIterable, Hashable {
    case collegeFootball = "College Football"
    case nfl = "NFL"
}

struct BettingAppView: View {
    @State private var selectedGameType = GameType.nfl
    @ObservedObject private var viewModel = bookViewModel()
    @State private var showingSheet = false

    var body: some View {
        NavigationView {
            
            VStack {
                Picker("", selection: $selectedGameType) {
                    ForEach(GameType.allCases, id: \.self) { gameType in
                        Text(gameType.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(.blue)
                .padding(.horizontal)
                HStack {
                    Text("Betting App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                }
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredGames, id: \.idd) { game in // HARDCODE NCAAF
                            BetRowView1(game: game)
                            }
                    }
                    .padding()
                }
            }
            .background(Color.white
                .edgesIgnoringSafeArea(.all)
            ).ignoresSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
    
    private var filteredGames: [Game] {
        switch selectedGameType {
        case .collegeFootball:
            // return array of college football games from your viewModel
            return viewModel.NCAAFGames
        case .nfl:
            // return array of NFL games from your viewModel
            return viewModel.NFLgames
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
    
    var body: some View {
      
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Text(game.homeTeam) // team name
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                     
                    
                    BetButton(betTeamType: .betHomeSpread, currentBetType: $betTeamType, title: titleStringH) {
                        betTeamType = .betHomeSpread
                        showingSheet.toggle()
                    }
                    
                    Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                    
                    BetButton(betTeamType: .over, currentBetType: $betTeamType, title: "o" + String(format: "%.0f", game.totalOver)) {
                                    betTeamType = .over
                                    showingSheet.toggle()
                                }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                HStack {
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    
                    BetButton(betTeamType: .betAwaySpread, currentBetType: $betTeamType, title: titleStringA) {
                        betTeamType = .betAwaySpread
                        showingSheet.toggle()
                    }
                    Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                    //Spacer()
                    BetButton(betTeamType: .under, currentBetType: $betTeamType, title: "u" + String(format: "%.0f", game.totalUnder)) {
                                    betTeamType = .under
                                    showingSheet.toggle()
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
    @State private var userRating: Double = 2
    @ObservedObject var viewModel = bookViewModel()
    @ObservedObject var ticketVM = ticketViewModel()
    @State private var groupNumber = 0
    @State private var parlayType = 1
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
//
//                Text("Create Your Bet")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .padding()
//
//                Spacer()
                
            }.frame(maxWidth:.infinity, alignment: .center)
                .padding(.leading)
            
            HStack {

                if viewModel.isGroupsLoaded {
                    Picker("Group", selection: $groupNumber) {
                        ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                            Text(viewModel.userGroups[index]).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                } else {
                    Text("Loading...")
                }
 
                Picker("Bet Type", selection: $parlayType) { // starts at 1 bc "1 leg"
                       Text("Straight #1").tag(1)
                       Text("Straight #2").tag(2)
                       Text("Straight #3").tag(3)
                       Text("Straight #4").tag(4)
                       Text("2leg #1").tag(5)
                       Text("2leg #2").tag(6)
                       Text("3leg").tag(7)
                       Text("8leg").tag(8)
                   }
                   .pickerStyle(WheelPickerStyle())
                
            }
            
            

            if betTeamType == .betAwaySpread {
                BetView(teamName: game.awayTeam, spread: game.awaySpread, betType: 1, userRating: $userRating)
            }
            if betTeamType == .betHomeSpread {
                BetView(teamName: game.homeTeam, spread: game.homeSpread, betType: 2, userRating: $userRating)
            }
            if betTeamType == .over {
                BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", spread: game.totalOver, betType: 3, userRating: $userRating)
            }
            if betTeamType == .under {
                BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", spread: game.totalUnder, betType: 4, userRating: $userRating)
            }
        
            
        Button(action: {
            print("groupNumber: \(groupNumber), betNumber: \(parlayType)")
            viewModel.uploadBet(groupNumber: groupNumber, betNumber: parlayType, team: whichTeam, betLine: userRating, betOdds: 100, betType: .spread)
                withAnimation {
                    dismiss()
                    betTeamType = .None
                }
            
               }) {
                   Text("Place Bet")
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
               }
        }.onAppear(perform: {
            if betTeamType == .betAwaySpread {
                userRating = game.awaySpread
                whichTeam = game.awayTeam

            }
            if betTeamType == .betHomeSpread {
                userRating = game.homeSpread
                whichTeam = game.homeTeam

            }
            if betTeamType == .over {
                userRating = game.totalOver
                whichTeam = "\(game.homeTeam) / \(game.awayTeam) o"
            }
            if betTeamType == .under {
                userRating = game.totalUnder
                whichTeam = "\(game.homeTeam)/\(game.awayTeam) u"
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
    var spread: Double
    //var extra: String
    var internalExtra: String {
        if userRating < 0 {
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
    @Binding var userRating: Double

    var body: some View {
        VStack{
            HStack {
                Text("\(teamName) \(internalExtra)\(String(format: "%.0f", userRating))")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            HStack {
                //Text("Spread/total:")
                  //  .font(.headline)
                Slider(value: $userRating, in: Double(spread - 5)...Double(spread + 5), step: 1)
                    .accentColor(Color(.green))
            }
            .padding()
            
            Text("To Win: $ \(String(format: "%.0f", spread/userRating * 100))") // sample algorithm
                .font(.largeTitle)
                .foregroundColor(.green)
            
            Divider()
        }
    }
}

struct BetButton: View { // consolidated
    let betTeamType: BetTeamType
    let currentBetType: Binding<BetTeamType>
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.blue)
                .padding()
                .background(Color(currentBetType.wrappedValue == betTeamType ? .gray : .white))
                .cornerRadius(currentBetType.wrappedValue == betTeamType ? 20 : 10)
                .shadow(color: currentBetType.wrappedValue == betTeamType ? .gray : .clear, radius: 5)
                .scaleEffect(currentBetType.wrappedValue == betTeamType ? 0.9 : 1.0)
                .animation(.spring(), value: 4)
        }
    }
}
