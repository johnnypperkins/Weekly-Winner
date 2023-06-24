import SwiftUI

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @State private var selectedGroup = 1 // Variable to track the selected group
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("Group", selection: $selectedGroup) {
                    Text("Group 1").tag(1)
                    Text("Group 2").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top)
                .onChange(of: selectedGroup) { newValue in
                    viewModel.fetchBets(groupNumber: newValue)
                }
                
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
        }
        .onAppear {
            viewModel.fetchBets(groupNumber: selectedGroup) // Fetch bets for selected group on view appear
        }
        .onDisappear {
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
