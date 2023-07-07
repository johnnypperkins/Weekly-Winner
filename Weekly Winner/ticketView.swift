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
            
            ScrollView {
                VStack {
                    SectionTitle(title: "Straight #1", betArray: viewModel.betArray1, maxBetsPlaced: 1)
                    SectionTitle(title: "Straight #2", betArray: viewModel.betArray2, maxBetsPlaced: 1)
                    SectionTitle(title: "Straight #3", betArray: viewModel.betArray3, maxBetsPlaced: 1)
                    SectionTitle(title: "Straight #4", betArray: viewModel.betArray4, maxBetsPlaced: 1)
                    SectionTitle(title: "2 Leg #1", betArray: viewModel.betArray5, maxBetsPlaced: 2)
                    SectionTitle(title: "2 leg #2", betArray: viewModel.betArray6, maxBetsPlaced: 2)
                    SectionTitle(title: "3 leg #1", betArray: viewModel.betArray7, maxBetsPlaced: 3)
                    SectionTitle(title: "5 leg #1", betArray: viewModel.betArray8, maxBetsPlaced: 5)
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

        var body: some View {
            VStack(alignment: .leading) {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Text(title)
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .padding(.leading) // Padding for the title
                            .frame(width: geometry.size.width * 0.65, alignment: .leading)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(LeftRoundedCorners(radius: 5))
                            
                        Text("Not Started")
                            .font(.subheadline)
                            .padding(.vertical, 5)
                            .frame(width: geometry.size.width * 0.35, alignment: .center)
                            .background(Color.red.opacity(0.3))
                            .clipShape(RightRoundedCorners(radius: 5))
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 30) // Adjust this to your desired title

                ForEach(betArray) { bet in
                    BetCard(bet: bet)
                }

                let emptyBoxesCount = max(0, maxBetsPlaced - betArray.count)
                ForEach(0..<emptyBoxesCount, id: \.self) { _ in
                    EmptyBetCard()
                }
            }
            .padding(.horizontal) // Applying padding to the VStack directly
        }

        struct BetCard: View {
            let bet: Bet

            var body: some View {
                HStack {
                    Text("\(bet.teamBetOn ?? "Null team") \(bet.betLine >= 0 ? "+" : "")\(bet.betLine, specifier: "%.0f")")
                        .font(.headline)
                        .foregroundColor(Color.blue)
                    Spacer()
                    Text("+\(bet.betOdds, specifier: "%.0f")")
                        .foregroundColor(Color.green)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // Ensuring padding on the sides
            }
        }

        struct EmptyBetCard: View {
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Empty Bet").font(.headline)
                }
                .padding()
                .background(Color(.systemGray3))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // Ensuring padding on the sides
            }
        }
    }
    
    struct LeftRoundedCorners: Shape {
        var radius: CGFloat = .infinity
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // top right
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // bottom right
                path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY)) // start of bottom left curve
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius,
                            startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius)) // end of top left curve
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius,
                            startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
        }
    }
    struct RightRoundedCorners: Shape {
        var radius: CGFloat = .infinity
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY)) // top left
                path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // start of top right curve
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius,
                            startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius)) // end of bottom right curve
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius,
                            startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom left
            }
        }
    }
    
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView()
    }
}
