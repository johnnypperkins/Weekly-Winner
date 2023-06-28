//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

enum GameType: String, CaseIterable {
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
                HStack {
                    Text("Betting App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding()
                    
                    Picker("", selection: $selectedGameType) {
                        ForEach(GameType.allCases, id: \.self) { gameType in
                            Text(gameType.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.NFLgames, id: \.idd) { game in
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
    
    /*private var filteredGames: [Game] {
        switch selectedGameType {
        case .collegeFootball:
            return ""
        case .nfl:
            return ""
        }
    }*/
}

struct BetRowView1: View {
    let game: Game
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betTeamType: BetTeamType = .None
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Text(game.homeTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    Button(action: {
                        betTeamType = .betHomeSpread
                        self.showingSheet.toggle()
                            }) {
                                Text("\(game.homeSpread, specifier: "%.1f")")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color(betTeamType == .betHomeSpread ? .gray : .white))
                                    .cornerRadius(10)
                                    .shadow(color: betTeamType == .betHomeSpread ? .gray : .clear, radius: 5)
                                    .scaleEffect(betTeamType == .betHomeSpread ? 0.9 : 1.0)
                                    .animation(.spring(), value: 4)
                            }
                    
                    Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                    
                    Button(action: {
                        betTeamType = .over
                        self.showingSheet.toggle()
                    }) {
                        HStack{
                            Text("o\(game.totalOver, specifier: "%.1f")")
                                .foregroundColor(.blue)
                                .padding()
                        }
                        .background(Color(betTeamType == .over ? .gray : .white))
                        .cornerRadius(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .shadow(color: betTeamType == .over ? .gray : .clear, radius: 5)
                        .scaleEffect(betTeamType == .over ? 0.9 : 1.0)
                        .animation(.spring(), value: 4)
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                HStack {
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        betTeamType = .betAwaySpread
                        self.showingSheet.toggle()
                            }) {
                                Text("\(game.awaySpread, specifier: "%.1f")")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color(betTeamType == .betAwaySpread ? .gray : .white))
                                    .cornerRadius(10)
                                    .shadow(color: betTeamType == .betAwaySpread ? .gray : .clear, radius: 5)
                                    .scaleEffect(betTeamType == .betAwaySpread ? 0.9 : 1.0)
                                    .animation(.spring(), value: 4)
                            }
                    Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                    //Spacer()
                    Button(action: {
                        betTeamType = .under
                        self.showingSheet.toggle()
                    }) {
                        HStack{
                            Text("u\(game.totalUnder, specifier: "%.1f")")
                                .foregroundColor(.blue)
                                .padding()
                        }
                        .background(Color(betTeamType == .under ? .gray : .white))
                        .cornerRadius(20)
                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                        .shadow(color: betTeamType == .under ? .gray : .clear, radius: 5)
                        .scaleEffect(betTeamType == .under ? 0.9 : 1.0)
                        .animation(.spring(), value: 4)
                    }
                    
                }.padding(.top,4)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            }
            //.padding(.leading)
            
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

struct BetDetailsView: View { // the pop up thing
    let game: Game
    @Binding var betTeamType: BetTeamType
    @Environment(\.dismiss) var dismiss
    @State private var userRating: Double = 2
    @ObservedObject var viewModel = bookViewModel()
    @State private var groupNumber = 0
    @State private var parlayType = "Straight"
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    
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
                
                Text("Create Your Bet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Spacer()
                
            }.frame(maxWidth:.infinity, alignment: .center)
                .padding(.leading)
            
//            Picker("Group", selection: $groupNumber) {
//                ForEach(viewModel.userGroups, id: \.self) { group in
//                    Text(group).tag(group)
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
            HStack {
                if viewModel.isGroupsLoaded {
                    Picker("Group", selection: $groupNumber) {
                        ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                            Text(viewModel.userGroups[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else {
                    Text("Loading...")
                }
                Picker("Bet Type", selection: $parlayType) {
                       Text("Straight").tag("Straight")
                       Text("2leg").tag("2leg")
                       Text("5leg").tag("5leg")
                   }
                   .pickerStyle(MenuPickerStyle())
            }
            
            
            
            if betTeamType == .betAwaySpread {
                BetView(teamName: game.awayTeam, spread: game.awaySpread, userRating: $userRating)
            }
            if betTeamType == .betHomeSpread {
                BetView(teamName: game.homeTeam, spread: game.homeSpread, userRating: $userRating)
            }
            if betTeamType == .over {
                BetView(teamName: game.awayTeam, spread: game.totalOver, userRating: $userRating)
            }
            if betTeamType == .under {
                BetView(teamName: game.awayTeam, spread: game.totalUnder, userRating: $userRating)
            }
        
            
        Button(action: {
            
            viewModel.uploadBet(groupNumber: groupNumber, team: whichTeam, betLine: userRating, betOdds: 100, betType: .spread)
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
                whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
            }
            if betTeamType == .under {
                userRating = game.totalUnder
                whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
            }
            print("view model.usergroups: \(viewModel.userGroups)")
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
    @Binding var userRating: Double

    var body: some View {
        VStack{
            Text("Team: \(teamName)")
                .font(.headline)
            
            HStack {
                Text("Choose odds:")
                    .font(.headline)
                Slider(value: $userRating, in: Double(spread - 5)...Double(spread + 5), step: 0.5)
                    .accentColor(Color(.green))
                
                Text(String(format: "%.1f", userRating))
                    .font(.headline)
            }
            .padding()
            
            Text("Spread: \(spread)")
                .font(.subheadline)
            
            Divider()
        }
    }
}
