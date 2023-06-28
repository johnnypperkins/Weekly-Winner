import SwiftUI

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @ObservedObject var bookVM = bookViewModel()
    @State private var selectedGroup = 0 // Variable to track the selected group
    
    var body: some View {
        ScrollView {
            VStack {
                Picker("Group", selection: $selectedGroup) { // Needs to be dependent on num of groups in. Will change later
                    Text("Global").tag(0)
                    Text("Group 2").tag(1)
                    Text("Group 3").tag(2)
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
                
                let emptyBoxesCount = max(0, 5 - viewModel.betArray1.count)
                let emptyBoxes = Array(0..<emptyBoxesCount)

                ForEach(emptyBoxes, id: \.self) { _ in
                    EmptyBetCard()
                }
                
                Text("2 leg parlays").font(.title).padding(.top)
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
    
    struct EmptyBetCard: View {
        var body: some View {
            VStack(alignment: .leading) {
                Text("Empty Bet").font(.headline)
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView()
    }
}
