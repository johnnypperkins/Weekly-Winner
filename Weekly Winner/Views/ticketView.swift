import SwiftUI
import Firebase
import Kingfisher
import SafariServices

struct ticketView: View {
    @ObservedObject var viewModel = ticketViewModel()
    @ObservedObject var bookVM = bookViewModel()
    //@ObservedObject var profileVM = profileViewModel(user: user)
    @State private var selectedGroup = 0 // Variable to track the selected group
    @ObservedObject var authViewModel = authenticationViewModel()
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
        viewModel.fetchStats(uid: uid) {

        }
        
        viewModel.fetchUserProfilePic(uid: uid) {
            
        }
    }
    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                if uid == Auth.auth().currentUser?.uid && onTicketPage{
                    Text("Tickets").font(.custom(K.customFonts.lexendDecaMedium, size: 20)).foregroundColor(K.finalColor.textWhite).padding(.bottom)
                    
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            
                            Button(action: {
                                //self.selectedGroup = index
                                //viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                timeFrame = "daily"
                                viewModel.isBetsLoaded = false
                                viewModel.isTFLoaded = false
                                if selectedWeek == "current" {
                                    viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: StaticUserData.shared.dailyTicket.ticketFormat, timeFrame: timeFrame, completion: {})
                                } else {
                                    viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, completion: {})
                                }
                            }) {
                                Text("Daily")
                                    .padding()
                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 115, height: 35, alignment: .center)
                                    .background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }

                            Button(action: {
                                //self.selectedGroup = index
                                //viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
                                timeFrame = "weekly"
                                viewModel.isBetsLoaded = false
                                viewModel.isTFLoaded = false
                                if selectedWeek == "current" {
                                    viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: StaticUserData.shared.weeklyTicket.ticketFormat, timeFrame: timeFrame, completion: {})
                                } else {
                                    viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, completion: {})
                                }
                            }) {
                                Text("Weekly")
                                    .padding()
                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 115, height: 35, alignment: .center)
                                    .background(timeFrame == "weekly" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }
                            
//                            ForEach(0..<viewModel.userTickets.count, id: \.self) { index in
//                                Button(action: {
//                                    self.selectedGroup = index
//                                    //viewModel.fetchUserTickets(uid: uid, groupNumber: selectedGroup) {
//                                    viewModel.isBetsLoaded = false
//                                    viewModel.isTFLoaded = false
//                                    if selectedWeek == "current" {
//                                        viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: viewModel.userTickets[selectedGroup].ticketFormat, timeFrame: timeFrame, completion: {})
//                                    } else {
//                                        viewModel.fetchPastBets(uid: uid, for: selectedGroup, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, completion: {})
//                                    }
//                                }) {
//                                    Text(viewModel.userTickets[index].groupName)
//                                        .padding()
//                                        .font(.custom(K.customFonts.lexendDecaLight, size: 16))
//                                        .foregroundColor(.white)
//                                        .frame(width: 115, height: 35, alignment: .center)
//                                        .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
//                                        .cornerRadius(5)
//                                }
//                            }
                            Spacer()
                        }
                    
                    
                } else {
                    if viewModel.isBetsLoaded {
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
                                    Text("Joined: " + formatDateMMDDYY(from: viewModel.userInfo!.dateJoined))
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                                        .foregroundColor(.white.opacity(0.75))
                                        .padding(.leading, 1)
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
                        //
                        
                    }
                    
                }
                
                if ticketShowing {
                    if (viewModel.isBetsLoaded) {
                        if (ticketIsEnabled) {
                            //                        if uid == Auth.auth().currentUser?.uid {
                            HStack (alignment: .center, spacing: 23){
                                HStack (spacing: 0) {
                                    Text("Pending").font(.custom("Futura", size: 16)).foregroundColor(K.finalColor.textWhite)
                                    Spacer()
                                    Text("\(String(format: "%.0f", viewModel.totalPotentialWon))")
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
                                    Text("\(String(format: "%.0f", viewModel.totalWon))")
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
                                            ForEach(0..<viewModel.totalBetArrays.count, id: \.self) { parlayIndex in
                                                if viewModel.currentTicketFormat.count > 0 && viewModel.isTFLoaded == true && viewModel.totalBetArrays.count == viewModel.currentTicketFormat.count {
                                                    if viewModel.isBetsLoaded {
                                                        SectionTitle(title: parlayTitle(ticketFormat: viewModel.currentTicketFormat, index: parlayIndex), betArray: viewModel.totalBetArrays[parlayIndex], maxBetsPlaced: viewModel.currentTicketFormat[parlayIndex], uid: Auth.auth().currentUser?.uid ?? "", selectedWeek: selectedWeek, ownTicket: ownTicket ? true : false, onTicketPage: onTicketPage, viewModel: viewModel, BookVM: bookVM)
                                                    }
                                                }
                                            }
                                        } else {
                                            ForEach(0..<viewModel.totalBetArrays.count, id: \.self) { parlayIndex in
                                                SectionTitle(title: parlayTitle(ticketFormat: ticketFormatForGroups, index: parlayIndex), betArray: viewModel.totalBetArrays[parlayIndex], maxBetsPlaced: ticketFormatForGroups[parlayIndex], uid: uid, selectedWeek: selectedWeek, ownTicket: ownTicket ? true : false, onTicketPage: onTicketPage, viewModel: viewModel, BookVM: bookVM)
                                            }
                                        }
                                        
                                    }.onAppear() {
                                        print("TOTAL BET ARRAY COUNT", viewModel.totalBetArrays.count)
                                        print("TICKET FORMAT FOR GROUPS", ticketFormatForGroups)
                                    }
                                    
                                }.padding(.bottom,65)
                                    .padding()
                            }
                            
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
                    groupStats(stat1: viewModel.stats?.totalBetsPlaced ?? 0, stat2: viewModel.stats?.totalBetsWon ?? 0, stat3: percentageToML(percentage: viewModel.stats?.avgOddsPlaced ?? 0), stat4: String(format: "%.1f",viewModel.stats?.betScore ?? 0))
                        .padding()
                }
                
                Spacer()
            }.padding(.top, onTicketPage ? 75 : 0)
            //.background(K.finalColor.backgroundBlue)
                .onAppear {
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
                        }
                        else {
                            viewModel.fetchPastFriendTicket(uid: uid, with: groupID) {_ in
                                viewModel.fetchPastBets(uid: uid, for: viewModel.userTickets[0].groupNumber, ticketFormat: ticketFormatForGroups, selectedWeek: selectedWeek, completion: {})
                            }
                        }
                        
                        viewModel.fetchUserInformation(uid: uid) {}
                        
                    } else {
                        //viewModel.fetchUserTickets(timeFrame: "weekly") { // CHANGE FROM TOP
                            viewModel.fetchBets(uid: uid, for: selectedGroup, ticketFormat: currentTicketFormat, timeFrame: timeFrame, completion: {}) // Fetch bets for selected group on view appear.
                            
                        //}
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
        let selectedWeek: String
        let ownTicket: Bool
        let onTicketPage: Bool
       // let totalOdds: Double
        @ObservedObject var viewModel: ticketViewModel
        @ObservedObject var BookVM: bookViewModel
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
                        
                        Text("\(title) | \(percentageToTotalWin(percentage: totalOdds))")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
//                        Text()
//                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
//                            .foregroundColor(.white)
                        //Spacer()
//                        HStack(alignment: .top, spacing: 17) {
////                            Text("\(percentageToML(percentage: totalOdds))")
////                                .font(.custom(K.customFonts.lexendDecaLight, size: 12))
////                                .foregroundColor(.white)
//                            
//                            
//                        }
                    }
                    .frame(height: 5)
                    .padding(.top, 10)
                    Rectangle()
                        .frame(height: 0.75)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 2, trailing: 0))
                        .foregroundColor(K.finalColor.textWhite.opacity(0.9))
                    
                    VStack(alignment: .center) {
                        let emptyBoxesCount = max(0, maxBetsPlaced - betArray.count)
                        let totalBetsCount = betArray.count + emptyBoxesCount

                        ForEach(0..<totalBetsCount, id: \.self) { index in
                            VStack(alignment: .center, spacing: 0) {
                                if index < betArray.count {
                                    BetCard(bet: betArray[index], uid: uid, selectedWeek: selectedWeek, ownCard: ownTicket, onTicketPage: onTicketPage, bookVM: BookVM, viewModel: viewModel)
                   
                                } else {
                                    EmptyBetCard(betArray: betArray)
                                }
                                if index != totalBetsCount - 1 {
                                    Divider()
                                }
                            }
                        }
                    }

                    //.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
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
            @ObservedObject var bookVM: bookViewModel
            @State private var game: Game? = nil
            @State var expand = false
            
            //let ownBets: Bool
            

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
                    let roundedBetLine = round(bet.betLine)
                    return "\(extra)\(Int(roundedBetLine))"
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
                                //Spacer()
                                Text(percentageToML(percentage: Double(bet.betOdds)))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
                                //.background(Color.backgroundForBetResult(bet.result))
                                //.background(K.gra)
                                //.cornerRadius(7.5)
                                Rectangle()
                                    .fill(Color.white) // Color of the separator
                                    .frame(width: 1, height: 20) // Adjust height as needed
                                //Spacer()
                                Text("\(bet.teamBetOn ?? "Null Team") \(lineFinal)")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size:
                                                    bet.teamBetOn?.count ?? 10 < 20 ? 16 : 13))
                                //   (bet.teamBetOn?.count ?? 10 > 35 ? 9: 11)))
                                
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
//                                                Text(" @")
//                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 8))
//                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                        }.frame(width: 220)
                                            .padding(.leading)
                                        Spacer()
                                        VStack {
                                            Text((game?.homeTeamScore ?? -1) >= 0 ? "\(game?.homeTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 20)
                                            Text((game?.awayTeamScore ?? -1) >= 0 ? "\(game?.awayTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 20)
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
                                    self.viewModel.deleteBet(bet: bet)
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
                        
                        bookVM.fetchGameDocument(byID: bet.gameID) { fetchedGame in
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

        struct EmptyBetCard: View {
            var betArray: [Bet]
            var body: some View {
                if betArray.contains(where: { $0.result.rawValue == "loss" }) {
                    Rectangle()
                        .fill(K.finalColor.deleteRed)
                        .frame(width: 320, height: 35)
                        .overlay(
                            Text("Forced Loss")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                        ).cornerRadius(7.5)

                } else {
                    Rectangle()
                        .fill(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(width: 291, height: 30)
                        .overlay(
                            Text("Empty Bet")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                        ).cornerRadius(5)
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

