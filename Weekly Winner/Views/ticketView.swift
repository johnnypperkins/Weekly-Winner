import SwiftUI

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @ObservedObject var bookVM = bookViewModel()
    @State private var selectedGroup = 0 // Variable to track the selected group
    
    var body: some View {
        VStack {
            if viewModel.isBetsLoaded {
                Picker("Group", selection: $selectedGroup) {
                    ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                        Text(viewModel.userGroups[index].groupName).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 10)
                .onChange(of: selectedGroup) { newValue in
                    viewModel.fetchBets(groupNumber: newValue, completion: {})
                }
            } else {
                Text("loading")
            }
            
            
            Text("Potential Winnings: $\(String(format: "%.0f", viewModel.totalPotentialWon))").font(.custom("Futura", size: 24))
            Text("Total Winnings: $\(String(format: "%.0f", viewModel.totalWon))").font(.custom("Futura", size: 24))
            
            ScrollView {
                VStack {
                    SectionTitle(title: "Straight #1", betArray: viewModel.betArray1, maxBetsPlaced: 1, viewModel: viewModel)
                    SectionTitle(title: "Straight #2", betArray: viewModel.betArray2, maxBetsPlaced: 1, viewModel: viewModel)
                    SectionTitle(title: "Straight #3", betArray: viewModel.betArray3, maxBetsPlaced: 1, viewModel: viewModel)
                    SectionTitle(title: "Straight #4", betArray: viewModel.betArray4, maxBetsPlaced: 1, viewModel: viewModel)
                    SectionTitle(title: "2 Leg #1", betArray: viewModel.betArray5, maxBetsPlaced: 2, viewModel: viewModel)
                    SectionTitle(title: "2 leg #2", betArray: viewModel.betArray6, maxBetsPlaced: 2, viewModel: viewModel)
                    SectionTitle(title: "3 leg #1", betArray: viewModel.betArray7, maxBetsPlaced: 3, viewModel: viewModel)
                    SectionTitle(title: "5 leg #1", betArray: viewModel.betArray8, maxBetsPlaced: 5, viewModel: viewModel)
                }
                .padding()
            }
        }.padding(.top,20)
        .onAppear {
            selectedGroup = 0
            viewModel.fetchUserGroups {
                viewModel.fetchBets(groupNumber: selectedGroup, completion: {}) // Fetch bets for selected group on view appear
            }
            
            
        }
        .onDisappear {
            selectedGroup = 0
            viewModel.stopListening() // Stop listening when view disappears
        }
        
    }
    
    
    
    struct SectionTitle: View {
        let title: String
        let betArray: [Bet]
        let maxBetsPlaced: Int
       // let totalOdds: Double
        @ObservedObject var viewModel: ticketViewModel
        
        var totalOdds: Double {
            var total: Double = 1
            for bet in betArray {
                total = total*Double(bet.betOdds)
            }
            return total
        }
        
        var hasLoss: Bool {
            return betArray.contains(where: { $0.result == .loss })
        }

        var body: some View {

            VStack(alignment: .leading) {
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Text(title)
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .padding(.leading) // Padding for the title
                            .frame(width: geometry.size.width * 0.50, alignment: .leading)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(LeftRoundedCorners(radius: 5))
                        Text("\(percentageToML(percentage: totalOdds))")
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .frame(width: geometry.size.width * 0.25, alignment: .center)
                            .background(Color.blue.opacity(0.3))
//                            .clipShape(RightRoundedCorners(radius: 5))
                        Text("\(percentageToTotalWin(percentage: totalOdds))")
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .frame(width: geometry.size.width * 0.25, alignment: .center)
                            .background(hasLoss ? K.lightRed : K.darkBlue.opacity(0.3))
                            .clipShape(RightRoundedCorners(radius: 5))
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 30) // Adjust this to your desired title
                
                VStack(spacing: 0) {
                    let emptyBoxesCount = max(0, maxBetsPlaced - betArray.count)
                    let totalBetsCount = betArray.count + emptyBoxesCount
                    
                    ForEach(0..<totalBetsCount, id: \.self) { index in
                        if index < betArray.count {
                            VStack(alignment: .leading, spacing: 0) {
                                BetCard(bet: betArray[index], viewModel: viewModel)
                                    .clipShape(RoundSomeCorners(topLeft: index == 0 ? 10 : 0, topRight: index == 0 ? 10 : 0,
                                                                bottomLeft: index == totalBetsCount - 1 ? 10 : 0, bottomRight: index == totalBetsCount - 1 ? 10 : 0))
                                if index != totalBetsCount - 1 {
                                    Divider()
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                EmptyBetCard()
                                    .clipShape(RoundSomeCorners(topLeft: index == 0 ? 10 : 0, topRight: index == 0 ? 10 : 0,
                                                                bottomLeft: index == totalBetsCount - 1 ? 10 : 0, bottomRight: index == totalBetsCount - 1 ? 10 : 0))
                                if index != totalBetsCount - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal) // Applying padding to the VStack directly
        }

        struct BetCard: View {
            let bet: Bet
            @ObservedObject var viewModel: ticketViewModel
            
            var extra: String {
                if bet.betType == .under {
                    return "u"
                } else if bet.betType == .over {
                    return "o"
                } else {
                    if bet.betLine >= 0 {
                        return "+"
                    }
                }
                return ""
            }

            var body: some View {
                HStack {
                    if bet.result == .notStarted { // ONLY SHOWS DELETE BUTTON IF .NOTSTARTED
                        Button(action: {
                            self.viewModel.deleteBet(bet: bet)
                        }) {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                        }
                    }
                    if bet.result == .forcedLoss {
                        Text("-")
                    } else {
                        Text("\(bet.teamBetOn ?? "Null team") \(extra)\(bet.betLine, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(K.darkBlue)
                        Spacer()
                        Text(percentageToML(percentage: Double(bet.betOdds)))
                            .foregroundColor(K.darkGreen)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity) // Move the frame to the bottom
                .background(Color.backgroundForBetResult(bet.result)) // changes color based on bet result
            }
        }

        struct EmptyBetCard: View {

            var body: some View {
                VStack(alignment: .leading) {
                    Text("Empty Bet").font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(K.veryLightGray)
            }
        }
    }
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView()
    }
}

