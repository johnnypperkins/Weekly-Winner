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
    @State private var selectedGameType = GameType.collegeFootball
    @ObservedObject private var viewModel = bookViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Betting App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                    
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
                        ForEach(viewModel.NFLgames) { game in
                            NavigationLink(destination: BetDetailsView(bet: createSampleBet())) {
                                //BetRowView1(game: game)
                                Text(game.awayTeam)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
        }.onAppear(perform: {viewModel.getGames()})
    }
    
    private var filteredGames: [Game] {
        switch selectedGameType {
        case .collegeFootball:
            return collegeFootballGames
        case .nfl:
            return nflGames
        }
    }
}

struct BetRowView1: View {
    let game: game
    
    var body: some View {
        Text("g")
    }
}

struct Game: Identifiable, Hashable {
    let id = UUID()
    let teams: [Team]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        lhs.id == rhs.id
    }
}

struct Team: Identifiable {
    let id = UUID()
    let name: String
    let spread: String
    let overUnder: String
}

struct Bet1: Identifiable {
    let id = UUID()
    let teams: [Team]
}

// Sample data for college football games
let collegeFootballGames: [Game] = [
    Game(teams: [
        Team(name: "Team A", spread: "+5", overUnder: "20"),
        Team(name: "Team B", spread: "-5", overUnder: "18")
    ]),
    Game(teams: [
        Team(name: "Team C", spread: "+2", overUnder: "15"),
        Team(name: "Team D", spread: "-2", overUnder: "25")
    ])
    // Additional college football games...
]

// Sample data for NFL games
let nflGames: [Game] = [
    Game(teams: [
        Team(name: "Team X", spread: "+7", overUnder: "30"),
        Team(name: "Team Y", spread: "-7", overUnder: "28")
    ]),
    Game(teams: [
        Team(name: "Team W", spread: "+3", overUnder: "22"),
        Team(name: "Team Z", spread: "-3", overUnder: "24")
    ])
    // Additional NFL games...
]

// Helper function to create a sample bet
func createSampleBet() -> Bet1 {
    return Bet1(teams: [
        Team(name: "Team A", spread: "+5", overUnder: "20"),
        Team(name: "Team B", spread: "-5", overUnder: "18")
    ])
}

struct BetDetailsView: View {
    let bet: Bet1
    
    var body: some View {
        VStack {
            Text("Bet Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            ForEach(bet.teams) { team in
                Text("Team: \(team.name)")
                    .font(.headline)
                
                Text("Spread: \(team.spread)")
                    .font(.subheadline)
                
                Text("Over/Under: \(team.overUnder)")
                    .font(.subheadline)
                
                Divider()
            }
            
            Spacer()
        }
    }
}

struct BetItemView: View {
    let team: Team
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 10) {
                    Text("Spread: \(team.spread)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text("Over/Under: \(team.overUnder)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding()
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
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}

