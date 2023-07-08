import SwiftUI

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @ObservedObject var bookVM = bookViewModel()
    @State private var selectedGroup = 0 // Variable to track the selected group
    
    var body: some View {
        VStack {
            Picker("Group", selection: $selectedGroup) { // Needs to be dependent on num of groups in. Will change later
                Text("Global").tag(0)
                Text("Group 2").tag(1)
                Text("Group 3").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
            .onChange(of: selectedGroup) { newValue in
                viewModel.fetchBets(groupNumber: newValue)
            }
            Text("Potential Winnings: ")
            Text("Total Winnings: ").font(.custom("Futura", size: 24))
            
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
        }
        .onAppear {
            viewModel.fetchBets(groupNumber: selectedGroup) // Fetch bets for selected group on view appear
        }
        .onDisappear {
            viewModel.stopListening() // Stop listening when view disappears
        }
        
    }
    
    
    
    struct SectionTitle: View {
        let title: String
        let betArray: [Bet]
        let maxBetsPlaced: Int
        @ObservedObject var viewModel: ticketViewModel

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
                        Text("Odds")
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .frame(width: geometry.size.width * 0.25, alignment: .center)
                            .background(Color.blue.opacity(0.3))
//                            .clipShape(RightRoundedCorners(radius: 5))
                        Text("To Win")
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .frame(width: geometry.size.width * 0.25, alignment: .center)
                            .background(Color.green.opacity(0.3))
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
//            var topLeft: CGFloat
//            var topRight: CGFloat
//            var bottomLeft: CGFloat
//            var bottomRight: CGFloat

            var body: some View {
                HStack {
                    Button(action: {
                        self.viewModel.deleteBet(bet: bet)
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
//                    .padding(.leading)
                    
                    Text("\(bet.teamBetOn ?? "Null team") \(bet.betLine >= 0 ? "+" : "")\(bet.betLine, specifier: "%.0f")")
                        .font(.headline)
                        .foregroundColor(K.darkBlue)
                    Spacer()
                    Text(returnML(percentage: Double(bet.betOdds)))
                        .foregroundColor(K.darkGreen)
                    
                    
                    
                }
                .padding()
                .frame(maxWidth: .infinity) // Move the frame to the bottom
                .background(K.veryLightBlue)
                
                //.modifier(ConditionalCornerRadius(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight))
                //.shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
            }
            
            
        }

        struct EmptyBetCard: View {
//            var topLeft: CGFloat
//            var topRight: CGFloat
//            var bottomLeft: CGFloat
//            var bottomRight: CGFloat

            var body: some View {
                VStack(alignment: .leading) {
                    Text("Empty Bet").font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(K.veryLightGray)
//                .overlay(
//                            RoundSomeCorners(topLeft: 10, topRight: 10, bottomLeft: 10, bottomRight: 10)
//                                .stroke(Color.gray, lineWidth: 1)
//                        )
                //.modifier(ConditionalCornerRadius(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight))
            }
        }

    }
    
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView()
    }
}

