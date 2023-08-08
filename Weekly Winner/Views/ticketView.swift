import SwiftUI
import Firebase

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @ObservedObject var bookVM = bookViewModel()
    @State private var selectedGroup = 0 // Variable to track the selected group
    @ObservedObject var authViewModel = authenticationViewModel()
    var username: String
    var uid: String
    var groupID: String

    
    init(username: String, uid: String, groupID: String) {
        self.username = username
        self.uid = uid
        self.groupID = groupID
        
        if uid != Auth.auth().currentUser?.uid{
            viewModel.fetchFriendTicket(uid: uid, with: groupID) { group in
                
            }
        }
        
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                if viewModel.isBetsLoaded && uid == Auth.auth().currentUser?.uid {
                    Text("Tickets").font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite).padding(.bottom)
                    if (viewModel.userTickets.count <= 3) {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                Button(action: {
                                    self.selectedGroup = index
                                    viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                        viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.currentTicketFormat, completion: {})
                                    }
                                }) {
                                    Text(viewModel.userTickets[index].groupName)
                                        .padding()
                                        .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 107, height: 35, alignment: .center)
                                        .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                        .cornerRadius(5)
                                }
                            }
                            Spacer()
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 10) {
                                ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                    Button(action: {
                                        self.selectedGroup = index
                                        viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                            viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.currentTicketFormat, completion: {})
                                        }
                                    }) {
                                        Text(viewModel.userTickets[index].groupName)
                                            .padding()
                                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                            .foregroundColor(.white)
                                            .frame(width: 105, height: 30, alignment: .center)
                                            .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                        }.padding(.leading)
                            .padding(.bottom,60)
                    }
                    
                } else {
                    if uid != Auth.auth().currentUser?.uid {
                        Text(viewModel.userTickets[0].groupName).font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                        Text(username).font(.custom(K.customFonts.lexendDecaMedium, size: 15)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                            
                    }
                    else{
                        Text("loading")
                    }
                    
                }

                if (viewModel.isBetsLoaded) {
                    if (viewModel.userTickets[selectedGroup].isEnabled) {
                        HStack (alignment: .center, spacing: 23){
                            HStack (spacing: 0) {
                                Text("Potential").font(.custom("Futura", size: 16)).foregroundColor(K.finalColor.textWhite)
                                Spacer()
                                Text("\(String(format: "%.0f", viewModel.totalPotentialWon))")
                                    .font(.custom("Futura", size: 20))
                                    .foregroundColor(K.finalColor.potentialOrange)
                            }.padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .frame(width: 160, height: 55, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .fill(K.finalColor.cardBlue) // Change the opacity as needed
                            )
                            .cornerRadius(7.5)
                            
                            HStack (spacing: 0){
                                Text("Total").font(.custom("Futura", size: 16)).foregroundColor(K.finalColor.textWhite)
                                Spacer()
                                Text("\(String(format: "%.0f", viewModel.totalWon))").font(.custom(K.customFonts.lexendDecaLight, size: 20)).foregroundColor(K.finalColor.winningGreen)
                            }
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .frame(width: 160, height: 55, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 7.5)
                                    .fill(K.finalColor.cardBlue) // Change the opacity as needed
                            )
                            .cornerRadius(7.5)
                            
                        }.padding([.horizontal,.top])
                        
                        ScrollView {
                            VStack {
//                                for parlayType in viewModel.userTickets[selectedGroup].ticketFormat {
//
//                                }
//                                SectionTitle(title: "Straight #1", betArray: viewModel.betArray1, maxBetsPlaced: 1, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "Straight #2", betArray: viewModel.betArray2, maxBetsPlaced: 1, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "Straight #3", betArray: viewModel.betArray3, maxBetsPlaced: 1, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "Straight #4", betArray: viewModel.betArray4, maxBetsPlaced: 1, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "2 Leg #1", betArray: viewModel.betArray5, maxBetsPlaced: 2, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "2 leg #2", betArray: viewModel.betArray6, maxBetsPlaced: 2, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "3 leg #1", betArray: viewModel.betArray7, maxBetsPlaced: 3, uid: uid, viewModel: viewModel)
//                                SectionTitle(title: "5 leg #1", betArray: viewModel.betArray8, maxBetsPlaced: 5, uid: uid, viewModel: viewModel)

                                    
                                    BetSections

                            }.padding(.bottom,60)
                            .padding()
                        }

                    } else {
                        Text("Ticket Disabled")
                    }
                } else {
                    Text("FreeWager")
                }
                Spacer()
            }.padding(.top, uid == Auth.auth().currentUser?.uid ? 75 : 0)
            //.background(K.finalColor.backgroundBlue)
                .onAppear {
                    selectedGroup = 0
                    if uid != Auth.auth().currentUser?.uid{
                        viewModel.fetchBets(uid: uid, for: viewModel.userTickets[0].groupNumber, ticketFormat: viewModel.currentTicketFormat, completion: {})
                    }
                    else{
                        viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                            viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.currentTicketFormat, completion: {}) // Fetch bets for selected group on view appear
                            
                        }
                    }
                }
                .onDisappear {
                    selectedGroup = 0
                    viewModel.stopListening() // Stop listening when view disappears
                }
            
        }
    }
    
    
    private var BetSections: some View {
        VStack {
            ForEach(0..<viewModel.currentTicketFormat.count, id: \.self) { index in
                let parlayType = viewModel.currentTicketFormat[index]
                ForEach(0..<parlayType, id: \.self) { i in
                    let betArray = viewModel.totalBetArrays[i + index * parlayType]
//                    let title = "Straight \(i+1)"
                    
                    SectionTitle(title: getTitle(for: index, iteration: i), betArray: betArray, maxBetsPlaced: index + 1, uid: uid, viewModel: viewModel)
                }
            }
        }
    }



    
    struct SectionTitle: View {
        let title: String
        let betArray: [Bet]
        let maxBetsPlaced: Int
        let uid: String
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
            ZStack {
                VStack (alignment: .leading) {
                    HStack() {
                        Text(title)
                            .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(alignment: .top, spacing: 17) {
                            Text("\(percentageToML(percentage: totalOdds))")
                                .font(.custom(K.customFonts.lexendDecaLight, size: 12))
                                .foregroundColor(.white)
                            Text("\(percentageToTotalWin(percentage: totalOdds))")
                                .font(.custom(K.customFonts.lexendDecaLight, size: 12))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 20)
                    .padding(.top, 10)
                    Rectangle()
                        .frame(height: 0.75)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 2, trailing: 0))
                        .foregroundColor(K.finalColor.textWhite)
                    
                    VStack(alignment: .center) {
                        let emptyBoxesCount = max(0, maxBetsPlaced - betArray.count)
                        let totalBetsCount = betArray.count + emptyBoxesCount

                        ForEach(0..<totalBetsCount, id: \.self) { index in
                            VStack(alignment: .center, spacing: 0) {
                                if index < betArray.count {
                                    BetCard(bet: betArray[index], uid: uid, viewModel: viewModel)
//                                        .clipShape(RoundSomeCorners(topLeft: index == 0 ? 10 : 0, topRight: index == 0 ? 10 : 0,
//                                                                    bottomLeft: index == totalBetsCount - 1 ? 10 : 0, bottomRight: index == totalBetsCount - 1 ? 10 : 0))
                                } else {
                                    EmptyBetCard()
//                                        .clipShape(RoundSomeCorners(topLeft: index == 0 ? 10 : 0, topRight: index == 0 ? 10 : 0,
//                                                                    bottomLeft: index == totalBetsCount - 1 ? 10 : 0, bottomRight: index == totalBetsCount - 1 ? 10 : 0))
                                }
                                if index != totalBetsCount - 1 {
                                    Divider()
                                }
                            }
                        }
                    }

                    //.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .frame(width: 311) // Removed the height: 35 constraint
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    //.cornerRadius(10)
                    .padding(.bottom, 5)
                }
                .frame(width: 311)
            }
            .frame(width: 343)
            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
            .cornerRadius(10)

            }

        struct BetCard: View {
            let bet: Bet
            let uid: String
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
                //HStack {
                    HStack {
                        HStack {
                            if bet.result == .forcedLoss {
                                Text("-")
                            } else {
                                Text("\(bet.teamBetOn ?? "Null team") \(extra)\(bet.betLine, specifier: "%.0f")")
                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(percentageToML(percentage: Double(bet.betOdds)))
                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    .foregroundColor(.white)
                            }
                        }.frame(maxWidth: .infinity, maxHeight: .infinity) // This line
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Color.backgroundForBetResult(bet.result))
                        .cornerRadius(7.5)
                        
                        if bet.result == .notStarted && uid == Auth.auth().currentUser?.uid { // ONLY SHOWS DELETE BUTTON IF .NOTSTARTED
                            Button(action: {
                                self.viewModel.deleteBet(bet: bet)
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red)

                            }
                        }
                    }
                    .frame(width: 291, height: 35)
                    
                    
                //}
            }
        }

        struct EmptyBetCard: View {
            var body: some View {
                Rectangle()
                    .fill(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .frame(width: 291, height: 30)
                    .overlay(
                        Text("Empty Bet")
                            .font(.custom(K.customFonts.lexendDecaLight, size: 14))
                            .foregroundColor(.white)
                    )
            }
        }

    }
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView(username: "Reid", uid: Auth.auth().currentUser!.uid, groupID: "")
    }
}

