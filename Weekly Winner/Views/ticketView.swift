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
    var selectedWeek: String
    var ticketFormatForGroups: [Int]
    var ticketIsEnabled: Bool {
        if selectedWeek != "current" {
            return true
        } else {
            if viewModel.userTickets[selectedGroup].isEnabled {
                return true
            } else {
                return false
            }
        }
    }

    
    init(username: String, uid: String, groupID: String, selectedWeek: String, ticketFormatForGroups: [Int]) {
        self.username = username
        self.uid = uid
        self.groupID = groupID
        self.selectedWeek = selectedWeek
        self.ticketFormatForGroups = ticketFormatForGroups
        
        if uid != Auth.auth().currentUser?.uid{
            viewModel.fetchFriendTicket(uid: uid, with: groupID) { group in
                
            }
            
        }
        
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                if uid == Auth.auth().currentUser?.uid {
                    Text("Tickets").font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite).padding(.bottom)
                    if (viewModel.userTickets.count <= 3) {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
                                Button(action: {
                                    self.selectedGroup = index
                                    //viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                    viewModel.isBetsLoaded = false
                                    if selectedWeek == "current" {
                                        viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, completion: {})
                                    } else {
                                        viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, selectedWeek: selectedWeek, completion: {})
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
                                        //viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                        if selectedWeek == "current" {
                                            viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, completion: {})
                                        }
                                        else {
                                            viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, selectedWeek: selectedWeek, completion: {})
                                        }
                                       // }
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
//                    if uid != Auth.auth().currentUser?.uid {
                        Text(viewModel.userTickets[0].groupName).font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                        Text(username).font(.custom(K.customFonts.lexendDecaMedium, size: 15)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                            
//                    }
//                    else{
//                        Text("loading")
//                    }
                    
                }

                if (viewModel.isBetsLoaded) {
                    if (ticketIsEnabled) {
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
                                VStack {
                                    if selectedWeek == "current" {
                                        ForEach(0..<viewModel.totalBetArrays.count, id: \.self) { parlayIndex in
                                            SectionTitle(title: parlayTitle(ticketFormat: viewModel.currentTicketFormat, index: parlayIndex), betArray: viewModel.totalBetArrays[parlayIndex], maxBetsPlaced: viewModel.userTickets[selectedGroup].ticketFormat[parlayIndex], uid: Auth.auth().currentUser?.uid ?? "", viewModel: viewModel)
                                        }
                                    } else {
                                        ForEach(0..<viewModel.totalBetArrays.count, id: \.self) { parlayIndex in
                                            SectionTitle(title: parlayTitle(ticketFormat: ticketFormatForGroups, index: parlayIndex), betArray: viewModel.totalBetArrays[parlayIndex], maxBetsPlaced: ticketFormatForGroups[parlayIndex], uid: uid, viewModel: viewModel)
                                        }
                                    }

                                }

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
                    print("ticket format for groups " + "\(ticketFormatForGroups)" + "\(viewModel.totalBetArrays.count)")
                    selectedGroup = 0
                    if uid != Auth.auth().currentUser?.uid{
                        if selectedWeek == "current" {
                            viewModel.fetchBets(uid: uid, for: viewModel.userTickets[0].groupNumber, ticketFormat: viewModel.userTickets[0].ticketFormat, completion: {})
                        }
                        else {
                            viewModel.fetchPastBets(uid: uid, for: viewModel.userTickets[0].groupNumber, ticketFormat: viewModel.userTickets[0].ticketFormat, selectedWeek: selectedWeek, completion: {})
                        }
                    }
                        
                    else{
                        if selectedWeek == "current"{
                            viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, completion: {}) // Fetch bets for selected group on view appear.
                                
                            }
                            
                        }
                        else {
                            viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, completion: {})
                        }
                    }
                }
                .onDisappear {
                    selectedGroup = 0
                    viewModel.stopListening() // Stop listening when view disappears
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
                                } else {
                                    EmptyBetCard()
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
        ticketView(username: "Reid", uid: Auth.auth().currentUser!.uid, groupID: "", selectedWeek: "current", ticketFormatForGroups: [])
    }
}

