//
//  screen3.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

enum Group: String, CaseIterable {
    case straightBets = "Straight Bets"
    case twoTeamParlays = "2-Team Parlays"
    case fiveTeamParlay = "5-Team Parlay"
}

struct FantasyFootballView: View {
    @State private var selectedGroup = Group.straightBets
    
    var body: some View {
        VStack {
            GroupPicker(selectedGroup: $selectedGroup)
            
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedGroup {
                    case .straightBets:
                        ForEach(straightBets, id: \.self) { bet in
                            BetRowView(bet: bet)
                        }
                    case .twoTeamParlays:
                        ForEach(twoTeamParlays, id: \.self) { bet in
                            BetRowView(bet: bet)
                        }
                    case .fiveTeamParlay:
                        ForEach(fiveTeamParlays, id: \.self) { bet in
                            BetRowView(bet: bet)
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
    }
}

struct GroupPicker: View {
    @Binding var selectedGroup: Group
    
    var body: some View {
        HStack {
            Text("Fantasy Football")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
            
            Picker("", selection: $selectedGroup) {
                ForEach(Group.allCases, id: \.self) { group in
                    Text(group.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .foregroundColor(.blue)
            .padding(.horizontal)
        }
    }
}

struct BetRowView: View {
    let bet: Bet
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(bet.tickets, id: \.self) { ticket in
                BetTicketView(ticket: ticket)
            }
        }
    }
}

struct Bet: Identifiable, Hashable {
    let id = UUID()
    let tickets: [Ticket]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Bet, rhs: Bet) -> Bool {
        lhs.id == rhs.id
    }
}

struct Ticket: Hashable {
    let team1: String
        let team2: String
        let spread1: String
        let spread2: String
        let overUnder: String
}

// Sample data for straight bets
let straightBets: [Bet] = [
    Bet(tickets: [
        Ticket(team1: "Team A", team2: "", spread1: "-3.5", spread2: "", overUnder: "45.5"),
        Ticket(team1: "Team B", team2: "", spread1: "+2.5", spread2: "", overUnder: "48.5")
    ]),
    Bet(tickets: [
        Ticket(team1: "Team C", team2: "", spread1: "+7.5", spread2: "", overUnder: "51.5"),
        Ticket(team1: "Team D", team2: "", spread1: "-5.5", spread2: "", overUnder: "47.5")
    ])
]

// Sample data for 2-team parlays
let twoTeamParlays: [Bet] = [
    Bet(tickets: [
        Ticket(team1: "Team A", team2: "Team B", spread1: "-3.5", spread2: "+2.5", overUnder: "45.5"),
        Ticket(team1: "Team C", team2: "Team D", spread1: "+7.5", spread2: "-5.5", overUnder: "51.5")
    ]),
    Bet(tickets: [
        Ticket(team1: "Team E", team2: "Team F", spread1: "-6.5", spread2: "+4.5", overUnder: "49.5"),
        Ticket(team1: "Team G", team2: "Team H", spread1: "+3.5", spread2: "-2.5", overUnder: "46.5")
    ])
]

// Sample data for 5-team parlay
let fiveTeamParlays: [Bet] = [
    Bet(tickets: [
        Ticket(team1: "Team A", team2: "Team B", spread1: "-3.5", spread2: "+2.5", overUnder: "45.5"),
        Ticket(team1: "Team C", team2: "Team D", spread1: "+7.5", spread2: "-5.5", overUnder: "51.5"),
        Ticket(team1: "Team E", team2: "Team F", spread1: "-6.5", spread2: "+4.5", overUnder: "49.5"),
        Ticket(team1: "Team G", team2: "Team H", spread1: "+3.5", spread2: "-2.5", overUnder: "46.5"),
        Ticket(team1: "Team I", team2: "Team J", spread1: "+1.5", spread2: "-3.5", overUnder: "44.5")
    ])
]

struct BetTicketView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                TeamView(name: ticket.team1, spread: ticket.spread1)
                TeamView(name: ticket.team2, spread: ticket.spread2)
            }
            
            OverUnderView(overUnder: ticket.overUnder)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct TeamView: View {
    let name: String
    let spread: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(name)
                .font(.headline)
            
            Text(spread)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OverUnderView: View {
    let overUnder: String
    
    var body: some View {
        Text("Over/Under: \(overUnder)")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
}

struct FantasyFootballView_Previews: PreviewProvider {
    static var previews: some View {
        FantasyFootballView()
    }
}
