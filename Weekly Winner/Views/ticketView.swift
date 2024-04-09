import SwiftUI
import Firebase
import Kingfisher
import SafariServices


struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @State private var selectedGroup = 0 // Variable to track the selected group
    @State var ticketShowing: Bool = true
    @State private var timeFrame: String
    
    var username: String
    var uid: String
    var groupID: String
    var selectedWeek: String
    var ticketFormatForGroups: [Int]
    var ownTicket: Bool
    var onTicketPage: Bool
    //@Binding var passedTimeFrame: String
    
    var ticketIsEnabled: Bool {
        if timeFrame == "weekly" {
            if selectedWeek != "current" {
                return true
            } else {
                if StaticUserData.shared.weeklyTicket.isEnabled || StaticUserData.shared.weeklyTicket.groupID == "Global" {
                    return true
                } else {
                    return false
                }
            }
        } else {
            if selectedWeek != "current" {
                return true
            } else {
                if StaticUserData.shared.dailyTicket.isEnabled || StaticUserData.shared.dailyTicket.groupID == "GlobalDaily" {
                    return true
                } else {
                    return false
                }
            }
        }
        
    }
    

    
    
    init(username: String, uid: String, groupID: String, selectedWeek: String, ticketFormatForGroups: [Int], ownTicket: Bool, onTicketPage: Bool, passedTimeFrame: String) {
        self.username = username
        self.uid = uid
        self.groupID = groupID
        self.selectedWeek = selectedWeek
        self.ticketFormatForGroups = ticketFormatForGroups
        self.ownTicket = ownTicket
        self.onTicketPage = onTicketPage
        self._timeFrame = State(initialValue: passedTimeFrame)
       

        if uid != Auth.auth().currentUser?.uid{
            viewModel.fetchFriendTicket(uid: uid, with: groupID, timeFrame: timeFrame) { group in
            }
        }
        
        viewModel.fetchUserInformation(uid: uid) {}
//        viewModel.fetchStats(uid: uid) {}
        viewModel.fetchUserBetsForStats(uid: uid) {}
        viewModel.fetchUserticketsForStats(uid: uid) {}
        viewModel.fetchUserProfilePic(uid: uid) {}
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            
            
            VStack {
                if uid == Auth.auth().currentUser?.uid && onTicketPage{
//                    onTicketHeader(viewModel: viewModel, 
//                                   timeFrame: $timeFrame,
//                                   uid: uid)
                } else {
                    if viewModel.isBetsLoaded {
                        offTicketHeader(viewModel: viewModel, 
                                        ticketShowing: $ticketShowing)
                    }
                }
                
                if ticketShowing {
                    if (viewModel.isBetsLoaded) {
                        if (ticketIsEnabled) {
                            
                            betsDisplay(uid: uid,
                                        selectedWeek: selectedWeek,
                                        ownTicket: ownTicket,
                                        onTicketPage: onTicketPage,
                                        ticketFormatForGroups: ticketFormatForGroups,
                                        timeFrame: $timeFrame,
                                        viewModel: viewModel)
                            
                        } else {
                            Text("Disabled, talk to admin.")
                                .font(.custom(K.customFonts.lexendDecaLight, size: 20))
                                .foregroundColor(.white)
                                .padding(.top, 75)
                        }
                    } else {
                        Text("")
                            .font(.custom(K.customFonts.lexendDecaLight, size: 15))
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                } else {
                    groupStats(allBets: viewModel.allDailyBets, allTickets: viewModel.allDailyTickets)
                        .padding()
                }
                
                Spacer()
            }
            //.background(K.finalColor.backgroundBlue)
                .onAppear {
                    Task{
                        await viewModel.isFriend(id: uid)
                    }
                    print("ticket format for groups " + "\(ticketFormatForGroups)" + "\(viewModel.totalBetArrays.count)")
                    selectedGroup = 0
                    let currentTicketFormat = {
                        if timeFrame == "daily" {
                            return StaticUserData.shared.dailyTicket.ticketFormat
                        } else {
                            return StaticUserData.shared.weeklyTicket.ticketFormat

                        }
                    }()
                    
                    
                    if !onTicketPage {
                        if selectedWeek == "current" {
                            viewModel.fetchFriendTicket(uid: uid, with: groupID, timeFrame: timeFrame) {_ in
                                viewModel.fetchBets(uid: uid, for: viewModel.userTickets[0].groupNumber, ticketFormat: currentTicketFormat, timeFrame: timeFrame, completion: {}) // usertickets is set to only one ticket here
                            }
                        } else {
                            viewModel.fetchPastFriendTicket(uid: uid, with: groupID, timeFrame: timeFrame) {_ in
                                viewModel.fetchPastBets(uid: uid, for: 0, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, timeFrame: timeFrame, completion: {})
                            }
                        }
                        
                        
                        
                    } else {
                        //viewModel.fetchUserTickets(timeFrame: "weekly") { // CHANGE FROM TOP
                            viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: currentTicketFormat, timeFrame: timeFrame, completion: {}) // Fetch bets for selected group on view appear.
                      //      viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: currentTicketFormat, timeFrame: timeFrame, completion: {}) // Fetch bets for selected group on view appear.
                            
                        //}
                    }
                }
                .onDisappear {
                    selectedGroup = 0
                    viewModel.stopListening() // Stop listening when view disappears
                }
            
            
        }
    }
    
    struct onTicketHeader: View {
        @ObservedObject var viewModel: ticketViewModel
        @Binding var timeFrame: String
        let uid: String
        
        var body: some View {
            VStack (spacing: 4){
                HStack (spacing: 0){

                    Text("Daily Ticket")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 40))
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50, alignment: .center)
                        //.background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                        .cornerRadius(5)

                }

            }.padding(.top, 23)
        }
    }
    
    struct offTicketHeader: View {
        
        @ObservedObject var viewModel: ticketViewModel
        @Binding var ticketShowing: Bool
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    if viewModel.profilePicUrl != "" {
                        KFImage(URL(string: viewModel.userInfo?.profileImageUrl ?? ""))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 80, height: 80)
                        
                    } else {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .cornerRadius(7.5)
                            .foregroundColor(K.finalColor.titleBlue)
                            .scaledToFit()
                            .frame(height: 80)
                    }
                    //Text(viewModel.userTickets[0].groupName).font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                    VStack (alignment: .leading, spacing: 0){
                        Text(viewModel.userInfo?.username ?? "").font(.custom(K.customFonts.lexendDecaMedium, size: 28)).foregroundColor(K.finalColor.textWhite)//.padding(.bottom)
                        
                        Text("Joined: " + formatDateMMDDYY(from: viewModel.userInfo?.dateJoined ?? Timestamp(date: Date())))
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                            .foregroundColor(.white.opacity(0.75))
                            .padding(.leading, 1)
                  
                        if viewModel.userInfo?.isCurrentUser != true {
                            Button(action: {
                                if viewModel.isFollow == true {
                                    viewModel.unfollow()
                                } else {
                                    viewModel.follow()
                                }
                            }, label: {
                                HStack {
                                    Text(viewModel.isFollow ? "Unfriend" : "Add Friend")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 2.5)
                                        .padding(.vertical, 1.5)
                                    
                                }
                                .background(viewModel.isFollow ? K.finalColor.potentialOrange : K.finalColor.winningGreen)
                                .cornerRadius(3)
                                .padding(.top, 3)
                            })
                            
                        }
                        
                    }
                    Spacer()
                }.padding(.top, 6)
                
                HStack (spacing: 5){
                    Button(action: {
                        ticketShowing = true
                    }, label: {
                        HStack {
                            Text("Ticket")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        }.frame(width: 100, height: 30)
                            .background(ticketShowing ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        
                    })
                    
                    Button(action: {
                        ticketShowing = false
                    }, label: {
                        HStack {
                            Text("Stats")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        }.frame(width: 100, height: 30)
                            .background(!ticketShowing ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        
                    })
                    
                }.padding(.bottom,6)
            }.background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal, 22.5)
        }
    }
    
    struct betsDisplay: View {
        let uid: String
        let selectedWeek: String
        let ownTicket: Bool
        let onTicketPage: Bool
        let ticketFormatForGroups: [Int]
        @Binding var timeFrame: String
        @ObservedObject var viewModel: ticketViewModel

        
        var body: some View {
            HStack (alignment: .center, spacing: 23){
                HStack (spacing: 0) {
                    Text("Pending").font(.custom("Futura", size: 16)).foregroundColor(K.finalColor.textWhite)
                    Spacer()
                    Text("\(Int(returnPotentialFromAllStraights(bets: viewModel.currentUserDailyBets)))")
                        .font(.custom("Futura", size: 20))
                        .foregroundColor(K.finalColor.potentialOrange)
                }.padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .frame(width: 160, height: 55, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 7.5)
                            .fill(K.finalColor.cardBlue) // Change the opacity as needed
                    ).cornerRadius(7.5)
                HStack (spacing: 0){
                    Text("Balance").font(.custom("Futura", size: 16)).foregroundColor(K.finalColor.textWhite)
                    Spacer()
                    Text("\(Int(returnWinningsFromAllStraights(bets: viewModel.currentUserDailyBets)))")
                        .font(.custom("Futura", size: 20))
                        .foregroundColor(viewModel.totalWon >= 0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
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
                            ForEach(0..<viewModel.currentUserDailyBets.count, id: \.self) { parlayIndex in
                                if viewModel.currentTicketFormat.count > 0
                                    && viewModel.isTFLoaded == true
                                    && viewModel.isBetsLoaded {
                                    SectionTitle(index: parlayIndex, betArray: viewModel.currentUserDailyBets, maxBetsPlaced: 1, uid: Auth.auth().currentUser?.uid ?? "", selectedWeek: selectedWeek, ownTicket: ownTicket ? true : false, onTicketPage: onTicketPage, timeFrame: $timeFrame, viewModel: viewModel)
                                    
                                }
                            }
                        } else {
                            ForEach(0..<viewModel.totalBetArrays.count, id: \.self) { parlayIndex in
                                SectionTitle(index: parlayIndex,betArray: viewModel.totalBetArrays[parlayIndex], maxBetsPlaced: ticketFormatForGroups[parlayIndex], uid: uid, selectedWeek: selectedWeek, ownTicket: ownTicket ? true : false, onTicketPage: onTicketPage, timeFrame: $timeFrame, viewModel: viewModel)
                            }
                        }
                        
                    }.onAppear() {
                        print("TOTAL BET ARRAY COUNT", viewModel.totalBetArrays.count)
                        print("TICKET FORMAT FOR GROUPS", ticketFormatForGroups)
                    }
                    
                }.padding(.bottom,65)
                    .padding()
            }
        }
    }
    
    struct SectionTitle: View {
        let index: Int
        let betArray: [Bet]
        let maxBetsPlaced: Int
        let uid: String
        let selectedWeek: String
        let ownTicket: Bool
        let onTicketPage: Bool
        @Binding var timeFrame: String
       // let totalOdds: Double
        @ObservedObject var viewModel: ticketViewModel
        @State var expand = false
        
        
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

        var statusColor: Color {
            if betArray.contains(where: { $0.result == .loss }) {
                return K.finalColor.deleteRed
            } else {
                if selectedWeek == "current" {
                    if betArray.count != maxBetsPlaced && (betArray.contains(where: { $0.result == .inAction }) || betArray.contains(where: { $0.result == .win })) {
                        return K.finalColor.cardBlue
                    } else if betArray.count == maxBetsPlaced && (betArray.contains(where: { $0.result == .inAction }) || betArray.contains(where: { $0.result == .notStarted})) {
                        return K.finalColor.cardBlue
                    } else if betArray.count == maxBetsPlaced  {
                        return K.finalColor.winningGreen
                    } else {
                        return K.finalColor.cardBlue
                    }
                } else {
                    if betArray.count != maxBetsPlaced {
                        return K.finalColor.deleteRed
                    } else {
                        return K.finalColor.winningGreen
                    }
                }
            }
        }
        
        
        var body: some View {
            ZStack {
                VStack (alignment: .leading) {
                    HStack() {
                        
                        Text("Straight \(index+1) | \(percentageToTotalWin(percentage: totalOdds))")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                    }
                    .frame(height: 5)
                    .padding(.top, 10)
                    Rectangle()
                        .frame(height: 0.75)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 2, trailing: 0))
                        .foregroundColor(K.finalColor.textWhite.opacity(0.9))
                    
                    VStack(alignment: .center) {
                        BetCard(bet: betArray[index], uid: uid, selectedWeek: selectedWeek, ownCard: ownTicket, onTicketPage: onTicketPage, ticketVM: viewModel, timeFrame: $timeFrame, viewModel: viewModel)
                    }

                    .frame(width: 311) // Removed the height: 35 constraint
                    .background(.clear)
                    //.cornerRadius(10)
                    .padding(.bottom, 5)
                }
                .frame(width: 320)
            }
            .frame(width: 343)
            .background(statusColor.opacity(0.65))
            .cornerRadius(10)

            }

        struct BetCard: View {
            
            let bet: Bet
            let uid: String
            let selectedWeek: String
            let ownCard: Bool
            let onTicketPage: Bool
            @State private var canDelete: Bool = false
            @State var moreInfoClicked = false
            @ObservedObject var ticketVM: ticketViewModel
            @State private var game: Game? = nil
            @State var expand = false
            @Binding var timeFrame: String
            

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
            
            var lineFinal: String {
                if bet.betLine == 0 {
                    return "ML"
                } else {
                    
                    return isWholeNumber(Double(bet.betLine)) ? "\(extra)\(String(format: "%.0f", bet.betLine))" : "\(extra)\(bet.betLine)"
                }
            }


            var body: some View {
                //HStack {
                
                HStack {
                    VStack (spacing: 0){
                        HStack (spacing: 0) {
                            if bet.result == .forcedLoss {
                                Text("-")
                            } else {
                                Text(percentageToML(percentage: Double(bet.betOdds)))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
                 
                                Rectangle()
                                    .fill(Color.white) // Color of the separator
                                    .frame(width: 1, height: 20) // Adjust height as needed
                                Text("\(bet.teamBetOn ?? "Null Team") \(lineFinal)")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size:
                                                    bet.teamBetOn?.count ?? 10 < 20 ? 16 : 13))
                                
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5))
                                    .cornerRadius(7.5)
                                    .frame(maxWidth: 250, alignment: .leading)
                                
                                Button {
                                    withAnimation {
                                        expand.toggle()
                                    }
                                } label: {
                                    if expand {
                                        Image(systemName: "chevron.down")
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.white)
                                            .frame(width: 30, height: 24)
                                            //.background()
                                    }
                                    else{
                                        Image(systemName: "chevron.up")
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.white)
                                            .frame(width: 30, height: 24)
                                    }
                                }
                            }
                        }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(bet.result == .notStarted ? K.finalColor.backgroundBlue : Color.backgroundForBetResult(bet.result))
                        if expand {
                            HStack {
                                VStack (spacing: 3){
                                    if bet.result == .notStarted {
                                        Rectangle()
                                            .fill(Color.white) // Color of the separator
                                            .frame(width: bet.result == .notStarted ? 240 : 300 , height: 1) // Adjust height as needed
                                    }
                                    HStack {
                                        VStack {
                                            HStack {
                                                Text("\(game?.homeTeam ?? "")")
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                            HStack(spacing: 0) {
                                                Text("\(game?.awayTeam ?? "")")
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                        }.frame(width: 220)
                                            .padding(.leading)
                                        Spacer()
                                        VStack {
                                            Text((game?.homeTeamScore ?? -1) >= 0 ? "\(game?.homeTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 30)
                                            Text((game?.awayTeamScore ?? -1) >= 0 ? "\(game?.awayTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 30)
                                        }.padding(.trailing)
                                        
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(game?.whichSport ?? "") | \(formatDateEMMMDHMM.format(date: game?.commenceTime.dateValue() ?? Date()))")
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: 10))
                                            .foregroundColor(K.finalColor.textWhite)
                                            //.frame(maxWidth: .infinity, alignment: .center)
                                        Spacer()
                                    }
                                }
                                
                            }.padding(EdgeInsets(top: 5, leading: 7.5, bottom: 5, trailing: 0))
                            .background(K.finalColor.backgroundBlue)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity) // This line
                    
                    .cornerRadius(7.5)
                        
                        if bet.result == .notStarted && uid == Auth.auth().currentUser?.uid && selectedWeek == "current" && ownCard && onTicketPage{ // ONLY SHOWS DELETE BUTTON IF .NOTSTARTED
                            Button(action: {
                                if canDelete {
                                    self.viewModel.deleteBet(bet: bet, timeFrame: timeFrame)
//                                    self.bookVM.fetchUserTickets(timeFrame: timeFrame) {
//                                        self.viewModel.fetchBets(uid: Auth.auth().currentUser?.uid, for: <#T##Int#>, ticketFormat: <#T##[Int]#>, timeFrame: <#T##String#>, completion: <#T##() -> Void#>)
//                                    }
                                }
                                canDelete = true
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(canDelete ? .red : .red.opacity(0.5))

                            }
                        }
                    }.background(bet.result == .notStarted ? Color.clear : Color.backgroundForBetResult(bet.result))
                    .cornerRadius(7.5)
                    .frame(width: 320)
                    .onAppear() {
                        canDelete = false
                        
                        ticketVM.fetchGameDocument(byID: bet.gameID) { fetchedGame in
                            if let fetchedGame = fetchedGame {
                                print("Fetched game: \(fetchedGame)")
                                self.game = fetchedGame
                            } else {
                                print("Failed to fetch game")
                                // Handle the error or absence of the game
                            }
                        }

                    }
                    .onDisappear() {
                        expand = false
                    }
            }
            
        }

    }
}

struct ticketView_Previews: PreviewProvider {
    static var previews: some View {
        ticketView(username: "Reid", uid: "", groupID: "", selectedWeek: "current", ticketFormatForGroups: [1,1,1], ownTicket: true, onTicketPage: true, passedTimeFrame: "daily")
    }
}



func returnWinningsFromAllStraights(bets: [Bet]) -> Double {
    var winnings = 0.0
    for bet in bets {
        if bet.result == .win {
            winnings += percentageToTotalWinDouble(percentage: Double(bet.betOdds))
        } else if bet.result == .loss {
            winnings -= 100
        }
    }
    return winnings
}


func returnPotentialFromAllStraights(bets: [Bet]) -> Double {
    var potential = 0.0
    for bet in bets {
        if bet.result == .inAction || bet.result == .notStarted {
            potential += percentageToTotalWinDouble(percentage: Double(bet.betOdds))
            print("THIS IS BET \(bet)")
            print("THIS IS potential \(potential)")
        }
    }
    return potential
}
