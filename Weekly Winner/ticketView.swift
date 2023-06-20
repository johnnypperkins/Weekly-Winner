//
//  screen3.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("1 leg bets").font(.title).padding(.top)
                ForEach(viewModel.betArray1) { bet in
                    betCard(bet: bet)
                }
                
                Text("2 paylay bets").font(.title).padding(.top)
                ForEach(viewModel.betArray2) { bet in
                    betCard(bet: bet)
                }
                
                Text("5 leg parlay").font(.title).padding(.top)
                ForEach(viewModel.betArray3) { bet in
                    betCard(bet: bet)
                }
            }
        }.onAppear {
            viewModel.fetchBets(groupNumber: 1) // Fetch bets for group 1 on view appear
        }.onDisappear {
            viewModel.stopListening() // Stop listening when view disappears
        }
    }
    
    func betCard(bet: Bet) -> some View {
            VStack(alignment: .leading) {
                Text("Team: \(bet.teamBetOn ?? "No team")").font(.headline)
                Text("Bet Type: \(bet.betType.rawValue)")
                Text("Bet Status: \(bet.betStatus.rawValue)")
                Text("Bet Result: \(bet.result.rawValue)")
                Text("Bet Line: \(bet.betLine)")
                Text("Bet Odds: \(bet.betOdds)")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            .padding(.horizontal)
        }
}
    
struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView()
    }
}
