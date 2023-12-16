//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import Kingfisher

struct groupsView: View {
    @State private var isJoinSheetPresented = false
    @State private var isGroupSettingsViewPresented: Bool = false
    @State private var isStatsViewPresented: Bool = false
    @State private var isGlobalPrizesShowing: Bool = false
    @State private var searchText = ""
    @State private var isShowingSheet = false
    @State private var isShowingSheetTicket = false
    @ObservedObject private var viewModel = groupsViewModel()
    @ObservedObject private var chatVM = chatViewModel()
    @State private var selectedGroup = 1
    @State private var showingChat: Bool = false
    @State private var currentWeekSelected: Bool = true
    @State private var timeFrame = "daily"
    
   // @State var selectedGroupBar: Group?
//    @State private var weekIndex: Int = -99
    //@State private var groupsFetched = false

    init() {

        viewModel.fetchCurrentRankedTickets(groupID: "GlobalDaily", timeFrame: "daily") {
        }
        

        
    }
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                searchText
            },
            set: {
                searchText = $0
                viewModel.fetchGroup(from: searchText)
            }
        )
        NavigationStack {
            if (StaticUserData.shared.weeklyTicket.groupID == "Global") {
                VStack {
                    Spacer()
                    VStack (spacing: 5){
                        HStack (spacing: 0){
                            Button(action: {
                                //viewModel.canGetHistoricalData = false
                                if timeFrame != "daily" {
                                    withAnimation {
                                        timeFrame = "daily"
                                        viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, timeFrame: timeFrame) {
                                        }
                                        showingChat = false
                                    }
                                }
                                
                            }) {
                                //Text(viewModel.userTickets[self.selectedGroup-1].groupName)
                                Text("Daily")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 35, alignment: .center)
                                    //.background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }.scaleEffect(timeFrame == "daily" ? 1.0 : 1.0)
                            
                            Button(action: {
                                //viewModel.canGetHistoricalData = false
                                if timeFrame == "daily" {
                                    
                                    withAnimation {
                                        timeFrame = "weekly"
                                        viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, timeFrame: timeFrame) {
                                        }
                                    }
                                }
                                
                            }) {
                                Text("Weekly")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 32))
                                    .foregroundColor(.white)
                                    .frame(width: 150, height: 35, alignment: .center)
                                    //.background(timeFrame == "weekly" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }.scaleEffect(timeFrame == "weekly" ? 1.0 : 1.0)
                        }
                        Rectangle()
                            .fill(Color.white) // Sets the rectangle's fill color to white
                            .frame(width: 140, height: 3)
                            .cornerRadius(1) // Apply rounded corners
                            .offset(x: timeFrame == "daily" ? -75 : 75, y: 0)
                            .animation(.easeInOut(duration: 0.5))
                    }.padding(8)
                       // .background(K.finalColor.cardBlue)
                        .cornerRadius(7.5)
                    
                    

                    if selectedGroup == 0 {
                        
                        
                    } else { // not looking for group
                        VStack {
                           // Spacer()
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        if viewModel.userGroupsLoaded {
                                            KFImage(URL(string: viewModel.userGroups[selectedGroup-1].groupImageURL))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipShape(Circle())
                                                .frame(width: 90, height: 90)
                                        } else {
                                            Image(systemName: "photo.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .background(K.finalColor.backgroundBlue)
                                                .clipShape(Circle())
                                                .frame(width: 90, height: 90 )
                                            
                                        }
                                        VStack (alignment: .leading, spacing: 0){
                                            HStack {
                                                //Text(viewModel.userTickets[selectedGroup-1].groupName)
                                                Text(timeFrame == "daily" ? "Dailyyy Challenge" : "Weekly Challenge")
                                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16     ))
                                                    .foregroundColor(.white)
                                                    .lineLimit(2)
                                                if StaticUserData.shared.weeklyTicket.groupID == "Global" {
                                                    Button(action: {
                                                        isGlobalPrizesShowing = true
                                                    }) {
                                                        Image("dollarSign")
                                                            .resizable()
                                                            .frame(width: 25, height: 25)
                                                        //.padding()
                                                            .foregroundColor(K.finalColor.winningGreen)
                                                            .padding(.leading, -5)
                                                    }
                                                    .sheet(isPresented: $isGlobalPrizesShowing) {
                                                        globalPrizesView()
                                                            .presentationDetents([.fraction(0.5)])
                                                    }
                                                }
                                            }
//                                            Text("\(viewModel.totalPlayers) Members")
//                                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
//                                                .foregroundColor(.white.opacity(0.75))
//                                                .padding(.leading, 3)
                                            if selectedGroup == 1 {
                                                Text("\(viewModel.currentRankedGroupTickets.count) Active")
                                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                                                    .foregroundColor(.white.opacity(0.75))
                                                    .padding(.leading, 3)
                                            }
                                        }
                 
                                        Spacer()
                                        
                                    }
                                }.padding(EdgeInsets(top: 40, leading: 20, bottom: 0, trailing: 16))
                            }
                            Spacer()
                            HStack {
                                VStack {
                                    if timeFrame == "weekly" {
                                        if (viewModel.canGetHistoricalData && !showingChat && viewModel.weekIndex >= 0 && viewModel.weekIndex <= viewModel.totalArrayOfDates[0].count) {
                                            HStack {
                                                Button(action: {
                                                    if viewModel.weekIndex < viewModel.totalArrayOfDates[0].count-1  {
                                                        viewModel.weekIndex = viewModel.weekIndex + 1
                                                        viewModel.fetchPastRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, week: viewModel.totalArrayOfDates[0][viewModel.weekIndex], timeFrame: timeFrame) {}
                                                    }
                                                }, label: {
                                                    if viewModel.weekIndex < viewModel.totalArrayOfDates[0].count-1  {
                                                        Image(systemName: "chevron.left")
                                                            .foregroundColor(.white)
                                                    } else {
                                                        Image(systemName: "chevron.left")
                                                            .foregroundColor(.white).opacity(0.6)
                                                    }
                                                })
                                                
                                                Text(viewModel.totalArrayOfDates[0][viewModel.weekIndex])
                                                    .foregroundColor(.white)
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                
                                                Button(action: {
                                                    if viewModel.weekIndex > 0 {
                                                        viewModel.weekIndex = viewModel.weekIndex - 1
                                                        if(viewModel.weekIndex == 0) {
                                                            viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, timeFrame: timeFrame) {}
                                                        } else {
                                                            viewModel.fetchPastRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, week: viewModel.totalArrayOfDates[0][viewModel.weekIndex], timeFrame: timeFrame) {}
                                                        }
                                                    }
                                                }, label: {
                                                    if viewModel.weekIndex > 0 {
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.white)
                                                    } else {
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.white).opacity(0.6)
                                                    }
                                                })
                                            }.padding(.leading)
                                            
                                            
                                            
                                        } else {
                                            Text("Test").foregroundColor(.clear)
                                        }
                                    } else if timeFrame == "daily" {
                                        if (viewModel.canGetHistoricalData && !showingChat && viewModel.dayIndex >= 0 && viewModel.dayIndex <= viewModel.totalArrayOfDates[0].count) {
                                            HStack {
                                                Button(action: {
                                                    if viewModel.dayIndex < viewModel.totalArrayOfDates[1].count-1  {
                                                        viewModel.dayIndex = viewModel.dayIndex + 1
                                                        viewModel.fetchPastRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, week: viewModel.totalArrayOfDates[1][viewModel.dayIndex], timeFrame: timeFrame) {}
                                                    }
                                                }, label: {
                                                    if viewModel.dayIndex < viewModel.totalArrayOfDates[1].count-1  {
                                                        Image(systemName: "chevron.left")
                                                            .foregroundColor(.white)
                                                    } else {
                                                        Image(systemName: "chevron.left")
                                                            .foregroundColor(.white).opacity(0.6)
                                                    }
                                                })
                                                
                                                Text(viewModel.totalArrayOfDates[1][viewModel.dayIndex])
                                                    .foregroundColor(.white)
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                
                                                Button(action: {
                                                    if viewModel.dayIndex > 0 {
                                                        viewModel.dayIndex = viewModel.dayIndex - 1
                                                        if(viewModel.dayIndex == 0) {
                                                            viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, timeFrame: timeFrame) {}
                                                        } else {
                                                            viewModel.fetchPastRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, week: viewModel.totalArrayOfDates[0][viewModel.dayIndex], timeFrame: timeFrame) {}
                                                        }
                                                    }
                                                }, label: {
                                                    if viewModel.dayIndex > 0 {
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.white)
                                                    } else {
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(.white).opacity(0.6)
                                                    }
                                                })
                                            }.padding(.leading)
                                        } else {
                                            Text("Test").foregroundColor(.clear)
                                        }
                                    }
                                }.frame(height: 25)
                                Spacer()
                                Button(action: {
                                    showingChat = false
                                }) {
                                    Image(showingChat ? "podiumUnselected" : "podiumSelected") // Assuming "ticket" and "ticket.fill" are your symbols
                                        .resizable()
                                        .frame(width: 25, height: 28)
                                        
                                }
                                
                                Button(action: {
                                    showingChat = true
                                }) {
                                    Image(showingChat ? "chatSelected" : "chatUnselected") // Assuming "message" and "message.fill" are your symbols
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(showingChat ? .blue : .gray)
                                }
                                
                                Button(action: {
                                    isStatsViewPresented = true
                                }) {
                                    Image("StatsUnselected")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                                .sheet(isPresented: $isStatsViewPresented) {
                                    statsView()
                                        .presentationDetents([.fraction(0.75)])
                                }
                                
                                if Auth.auth().currentUser?.uid == "fg57TZhmLmWH9TT3WCA3WuXT7dy2" { // reidbrown1 id
                                    Button(action: {
                                        isGroupSettingsViewPresented = true
                                    }) {
                                        Image(systemName: "gearshape")
                                            .resizable()
                                            .frame(width: 20, height: 21)
                                        //.padding()
                                            .foregroundColor(.white)
                                    }
                                    .sheet(isPresented: $isGroupSettingsViewPresented) {
                                        
                                        groupSettingsView(selectedGroup: $selectedGroup, viewModel: viewModel, groupAdmin: StaticUserData.shared.weeklyTicket.groupAdmin, groupNum: 0,
                                                          ticketFormat: timeFrame == "weekly" ? StaticUserData.shared.weeklyTicket.ticketFormat : StaticUserData.shared.dailyTicket.ticketFormat, timeFrame: timeFrame)
                                            .presentationDetents([.fraction(0.75)])
                                    }
                                }
                                
                            }.padding(EdgeInsets(top: 5, leading: 5, bottom: 10, trailing: 16))
                        }.frame(height: 130)
                            .padding(.bottom, 7.5)

                        Divider().background(.white).padding(EdgeInsets(top: 10, leading: 18, bottom: 4.5, trailing: 18))
                        VStack(alignment: .leading, spacing: 0) {
                            if !showingChat {
                                if timeFrame == "weekly" {
                                    if viewModel.weekIndex == 0 {
                                        currentLeaderboardView(viewModel: viewModel, selectedGroup: $selectedGroup, timeFrame: $timeFrame)
                                        //Spacer()
                                    } else {
                                        pastLeaderboardView(viewModel: viewModel, selectedGroup: $selectedGroup, selectedWeek: $viewModel.weekIndex, timeFrame: $timeFrame)
                                    }
                                } else if timeFrame == "daily" {
                                    if viewModel.dayIndex == 0 {
                                        currentLeaderboardView(viewModel: viewModel, selectedGroup: $selectedGroup, timeFrame: $timeFrame)
                                        //Spacer()
                                    } else {
                                        pastLeaderboardView(viewModel: viewModel, selectedGroup: $selectedGroup, selectedWeek: $viewModel.dayIndex, timeFrame: $timeFrame)
                                    }
                                }
                        
                                
                                
                            } else {
                                chatView(viewModel: chatVM, selectedGroup: $selectedGroup, groupsViewModel: viewModel, timeFrame: $timeFrame)
                            }
                            // .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius to the ScrollView
                            
                            
                        }
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 40, trailing: 16))
                        //.clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius to the ScrollView
                        
                    }
                    Spacer()
                }
                .sheet(isPresented: $isShowingSheet, content: {
                    createGroupsView()
                })
                .onChange(of: isShowingSheet) { newValue in
                    if newValue == false {
                        // The sheet was dismissed
                        selectedGroup = 1
                        print("onChange ranked")
                        if timeFrame == "daily" {
                            viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, timeFrame: timeFrame) {}
                        } else {
                            viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, timeFrame: timeFrame) {}
                        }                   
                    }
                }
                .onAppear(){
                    if selectedGroup > 0 {
                        print("on appear ranked")
                    }
                }
            }
        }.navigationTitle("Groups")
            .onAppear() {
                
            }.padding(.top, 50)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

extension UISegmentedControl {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setContentHuggingPriority(.defaultLow, for: .vertical)  // << here !!
    }
}

struct groupBarView: View {
    
    var group: Group // Groups99
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    if group.groupImageURL != ""{
                        KFImage(URL(string: group.groupImageURL))
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("\(group.groupName)")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            if group.password != "" {
                                Text("Private Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                            else{
                                Text("Public Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        Text("\(group.groupSlogan)")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                              .foregroundColor(.white)
                    }
                    Spacer()
                    
                }
                HStack {
                    Text("Group Admin")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                      .foregroundColor(.white)
                    Spacer()
                    Text(group.groupAdminUsername)
                      .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                      .foregroundColor(.white)
                }
                .padding(.top,10)

                HStack{
                    Spacer()
                    
                    Text("Join")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                                    //shadow
                    
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 40 , maxHeight: 40)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.top,10)
                
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal,15)
                .padding(.vertical,20)
        }
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .cornerRadius(10)
        .padding(.horizontal,16)
    }
}

struct currentLeaderboardView: View {
    @ObservedObject var viewModel: groupsViewModel
    @Binding var selectedGroup: Int
    @Binding var timeFrame: String

    var body: some View {
        VStack (spacing: 0) {
            if selectedGroup > 0 {
                HStack {
                    Text("My Ticket")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                        .foregroundColor(.white.opacity(0.75))
                        .padding(EdgeInsets(top: 0, leading: 2, bottom: 6, trailing: 0))
                    Spacer()
                }
                NavigationLink(destination:
                                ticketView(username: StaticUserData.shared.username, uid: StaticUserData.shared.dailyTicket.uid, groupID: timeFrame == "weekly" ? "Global" : "GlobalDaily", selectedWeek: "current", ticketFormatForGroups: [], ownTicket: true, onTicketPage: false, passedTimeFrame: timeFrame),
                               label: {
                    if timeFrame == "weekly" {
                        BetCard(viewModel: viewModel, ticket: StaticUserData.shared.weeklyTicket, rank: StaticUserData.shared.weeklyTicket.rank, ownCard: true, currentWeek: true, homePage: false).padding(.bottom,16)
                    } else {
                        BetCard(viewModel: viewModel, ticket: StaticUserData.shared.dailyTicket, rank: StaticUserData.shared.dailyTicket.rank, ownCard: true, currentWeek: true, homePage: false).padding(.bottom,16)
                    }
                }).id(UUID())
            }
            HStack {
                Text("Leaderboard")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 6, trailing: 0))
                Spacer()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<viewModel.currentRankedGroupTickets.count, id: \.self) { index in
                        //if (viewModel.currentRankedGroupTickets[index].uid != Auth.auth().currentUser?.uid) {
                            NavigationLink(destination:
                                            ticketView(username: viewModel.currentRankedGroupTickets[index].username, uid: viewModel.currentRankedGroupTickets[index].uid, groupID: viewModel.currentRankedGroupTickets[index].groupID, selectedWeek: "current", ticketFormatForGroups: [], ownTicket: viewModel.currentRankedGroupTickets[index].uid == Auth.auth().currentUser?.uid ? true : false, onTicketPage: false, passedTimeFrame: timeFrame), // FIX LATER ?
                                           label: {
                                BetCard(viewModel: viewModel, ticket: viewModel.currentRankedGroupTickets[index], rank: (viewModel.currentRankedGroupTickets[index].rank), ownCard: viewModel.currentRankedGroupTickets[index].uid == Auth.auth().currentUser?.uid ? true : false, currentWeek: true, homePage: false).padding(.bottom,16)
                            }).id(UUID())
//                        } else {
//                            // doesnt click if its yourself
//                            BetCard(viewModel: viewModel, ticket: viewModel.currentRankedGroupTickets[index], rank: (viewModel.currentRankedGroupTickets[index].rank), ownCard: true, currentWeek: true).padding(.bottom,16)
//
//                        }
                    }
                }
                .onAppear(){
                    //viewModel.printTickets(ticket: viewModel.currentRankedGroupTickets)
                    
                }
            }.padding(.bottom,40)
            .refreshable {
                await viewModel.fetchUserTickets(timeFrame: timeFrame) {}
                if selectedGroup != 0 {
                    //print("refresh ranked")
                    if timeFrame == "daily" {
                        viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, timeFrame: timeFrame) {}
                    } else {
                        viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.weeklyTicket.groupID, timeFrame: timeFrame) {}
                    }                }
            }.onAppear() {
                //print("\(viewModel.currentRankedGroupTickets.count) is count")
            }
        }
    }
}

struct pastLeaderboardView: View {
    @ObservedObject var viewModel: groupsViewModel
    @Binding var selectedGroup: Int
    @Binding var selectedWeek: Int
    @Binding var timeFrame: String
    
    var body: some View {
        VStack (spacing: 0) {
            ForEach(0..<viewModel.pastRankedGroupTickets.count, id: \.self) { index in
                if viewModel.pastRankedGroupTickets[index].uid == Auth.auth().currentUser?.uid {
                    HStack {
                        Text("My Ticket")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                            .foregroundColor(.white.opacity(0.75))
                            .padding(EdgeInsets(top: 0, leading: 2, bottom: 6, trailing: 0))
                        Spacer()
                    }
                    NavigationLink(destination:
                                    ticketView(username: viewModel.pastRankedGroupTickets[index].username, uid: viewModel.pastRankedGroupTickets[index].uid, groupID: viewModel.pastRankedGroupTickets[index].groupID, selectedWeek: selectedGroup > 0 ? "\(viewModel.totalArrayOfDates[selectedGroup-1][selectedWeek])" : "", ticketFormatForGroups: viewModel.pastRankedGroupTickets[index].ticketFormat, ownTicket: false, onTicketPage: false, passedTimeFrame: timeFrame),
                                   label: {
                        BetCard(viewModel: viewModel, ticket: viewModel.pastRankedGroupTickets[index], rank: (viewModel.pastRankedGroupTickets[index].rank), ownCard: true, currentWeek: false, homePage: false).padding(.bottom,16)
                    }).id(UUID())
                }
            }
            HStack {
                Text("Leaderboard")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 6, trailing: 0))
                Spacer()
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<viewModel.pastRankedGroupTickets.count, id: \.self) { index in
                            NavigationLink(destination:
                                            ticketView(username: viewModel.pastRankedGroupTickets[index].username, uid: viewModel.pastRankedGroupTickets[index].uid, groupID: viewModel.pastRankedGroupTickets[index].groupID, selectedWeek: selectedGroup > 0 ? "\(viewModel.totalArrayOfDates[selectedGroup-1][selectedWeek])" : "", ticketFormatForGroups: viewModel.pastRankedGroupTickets[index].ticketFormat, ownTicket: false, onTicketPage: false, passedTimeFrame: timeFrame),
                                           label: {
                                BetCard(viewModel: viewModel, ticket: viewModel.pastRankedGroupTickets[index], rank: (viewModel.pastRankedGroupTickets[index].rank), ownCard: viewModel.pastRankedGroupTickets[index].uid == Auth.auth().currentUser?.uid ? true : false, currentWeek: false, homePage: false).padding(.bottom,16)
                            }).id(UUID())
                        }

                }.padding(.bottom,60)
                    .onAppear(){
                       // viewModel.printTickets(ticket: viewModel.pastRankedGroupTickets)
                    }
            }
            .onAppear() {
                print("\(viewModel.pastRankedGroupTickets.count) is count")
            }
        }
    }
}

struct BetCard: View {
    @ObservedObject var viewModel: groupsViewModel
//    @ObservedObject var profileViewModel: profileViewModel
    let ticket: Ticket
    let rank: String
    let ownCard: Bool
    let currentWeek: Bool
    let homePage: Bool
    @State private var profileImageURL = ""
    var adminCard: Bool {
        if ticket.groupAdmin == ticket.uid {
            return true
        } else {
            return false
        }
    }
    @State private var isEnabled: Bool = false // New State variable
//    @State private var oldValue: Bool = false

    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                HStack {
                    HStack(spacing: 11) {
                        HStack(spacing: 0) {
                            
                            Text("\(ticket.isEnabled ? "\(rank)." : "-")")
                                .font(Font.custom(K.customFonts.poppinsMedium, size: 12).weight(.medium))
                                .foregroundColor(.white)
                                .padding(.leading,3)
                        }
                        .frame(maxHeight: .infinity)
                        HStack(spacing: 5) {
                            if profileImageURL != "" {
                                KFImage(URL(string: profileImageURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 24, height: 24)
                                    .background(K.finalColor.tabSelectedBlue)
                                    .clipShape(Circle())

                            }
                            HStack(spacing: 0){
                                Text("\(ticket.username) ")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                Text("\(ticket.groupAdmin == ticket.uid ? "(A)": "") ")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                    .foregroundColor(.red)
                            }
                            HStack(spacing: 0) {
                                if rank == "1" || rank == "T1" && ticket.totalWon > 0{
                                    Image(systemName: "trophy.fill")// lmao fuck with this johnny
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Color(hex: "D4AF37"))
                                } else if rank == "2" || rank == "T2" && ticket.totalWon > 0{
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Color(hex: "C0C0C0"))
                                }
                                else if rank == "3" || rank == "T3" && ticket.totalWon > 0{
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(Color(hex: "9F7A34"))
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(height: 24)
                    
                    Spacer()
                    HStack(alignment: .top, spacing: 10) {
                        if currentWeek {
                            HStack (alignment: .center) {
                                Text("\(ticket.totalPotentialWon)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(K.finalColor.potentialOrange)
                                    .frame(width: 45, height: 20, alignment: .center)
                            }
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .background(K.finalColor.potentialOrange.opacity(0.1))
                            .cornerRadius(5)
                        }
                        HStack (alignment: .center) {
                            Text("\(ticket.totalWon)")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(ticket.totalWon>=0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                .frame(width: currentWeek ? 45 : 110, height: 20, alignment: .center)
                        }
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .background(K.finalColor.winningGreen.opacity(0.1))
                        .cornerRadius(5)
                        .padding(.trailing, currentWeek ? 0 : 0)
                        
                    }
                    .frame(maxHeight: .infinity)
                    
                    
                    
                    // Arrow
                    if homePage == false {
                        HStack {
                            Image(systemName: "chevron.right") // Use any image you'd like
                                .resizable()
                                .frame(width: 7.5, height: 10) // Adjust size to your liking
                                .foregroundColor(ticket.isEnabled ? .white : .clear) // Choose color
                            //.padding(.trailing,2.5) // Add padding to move away from the edge
                        }
                    }
                    
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                HStack {
                    Spacer()
                    if(!ownCard && ticket.groupAdmin == Auth.auth().currentUser?.uid && currentWeek) {
                        Button(ticket.isEnabled ? "Enabled" : "Disabled", action: {
//                            viewModel.updateIsEnabled(ticket: self.ticket, isEnabled: ticket.isEnabled ? false : true) {_ in
//                                viewModel.fetchCurrentRankedTickets(groupID: ticket.groupID) {}
//                            }
                        }).foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaLight, size: 12))
//                        .foregroundColor(!ticket.isEnabled ? Color.red : K.darkGreen)
                    }
                    Spacer()
                }.background(!ticket.isEnabled ? K.finalColor.deleteRed : K.finalColor.winningGreen)
                    //.padding(.bottom,10)

            }
        }
        .opacity(ticket.isEnabled || ticket.groupAdmin == Auth.auth().currentUser?.uid ? 1 : 0.66)
        .padding(.vertical, 10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: ticket.groupAdmin != Auth.auth().currentUser?.uid || ticket.username == StaticUserData.shared.username ? 44 : 44)
        .background(ownCard ? K.finalColor.otherPurple.opacity(0.35): K.finalColor.cardBlue)
        .cornerRadius(10)
        //.overlay(ownCard ? RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1) : RoundedRectangle(cornerRadius: 10).stroke(Color.clear, lineWidth: 0))
        //.shadow(color: ownCard ? Color.white : Color.clear, radius: ownCard ? 2.5 : 0, x: 0, y: 0)


        
        .onAppear {
            isEnabled = ticket.isEnabled
            //print(ticket.uid)
            viewModel.fetchUserProfilePic(uid: ticket.uid) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                   //print("Profile image URL: \(profileImageUrl)")
                    self.profileImageURL = profileImageUrl
                }
            }
        }
    }
}



struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            HStack() {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty, placeholder: {
                        Text("Find a group...").foregroundColor(.gray)
                    })
                    .foregroundColor(.white)
                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                    .accentColor(.white)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)


            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .cornerRadius(15)
        }
        .padding(.top, 10)
        .padding(.horizontal,16)
    }
}




struct GroupJoinSheet: View {
    let group: Group // Groups99
    let viewModel: groupsViewModel
    @Binding var isPresented: Bool
    @State var canJoin = true
    @State var adminUsername = ""
    @State var enteredPassword = ""
    @ObservedObject private var authVM = authenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        
        VStack {
            ZStack(){
                VStack {
                    if (canJoin) {
                        Text("Join Group")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                            .foregroundColor(.white)
                    }
                }
                HStack(){
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            
                    }.padding(.trailing,16)
                    
                }.frame (minWidth: 0, maxWidth: .infinity)
            }.frame (minWidth: 0, maxWidth: .infinity)
            
            VStack(alignment: .leading){
                HStack{
                    if group.groupImageURL != ""{
                        KFImage(URL(string: group.groupImageURL))
                            .resizable()
                            .cornerRadius(20)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("\(group.groupName)")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            if group.password != "" {
                                Text("Private Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                            else{
                                Text("Public Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        Text("\(group.groupSlogan)")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                              .foregroundColor(.white)
                    }
                    Spacer()
                    
                }
                HStack {
                    Text("Group Admin")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                      .foregroundColor(.white)
                    Spacer()
                    Text(group.groupAdminUsername)
                      .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                      .foregroundColor(.white)
                }
                .padding(.top,10)
                
                if !group.password!.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            TextField("Password", text: $enteredPassword)
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .cornerRadius(10)
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                }
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal,15)
                .padding(.vertical,20)
            
            if (canJoin) {
                Button(action: {
                    if enteredPassword != group.password {
                        AppUtility.shared.showCustomAlert(alertType: .none, message: "The password that you entered is invalid. Please check with the admin and rejoin.", actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.ok) { action in
                            
                        }
                    }
                    else{
                        AppUtility.shared.showCustomAlert(alertType: .none, message: "Congratulations, you have joined \(group.groupName)", actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.ok) { action in
                               // viewModel.joinGroup(group: group)
                                isPresented = false
                        }
                    }
                }, label: {
                    HStack{
                        Spacer()
                        
                        Text("Join")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(.white)
                                        //shadow
                        
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                        .background(Color(red: 0.31, green: 0.57, blue: 1))
                        .cornerRadius(10)
                        .padding(.top,10)
                })
                .padding()
            } else {
                HStack{
                    Spacer()
                    
                    Text("Join")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                                    //shadow
                    
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 40 , maxHeight: 40)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.top,10)
            }
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .padding()
        .onAppear() {
//            viewModel.checkIfGroupAlreadyJoined(group: group) { (alreadyJoined) in
//                if !alreadyJoined {
//                    canJoin = true
//                } else {
//                    canJoin = false
//                }
//            }
            authVM.fetchUserInformation(uid: group.groupAdmin) { (user) in
                if let user = user {
                    adminUsername = user.username
                } else {
                    adminUsername = group.groupAdmin
                }
            }
        }
        .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

struct chatView: View {
    @ObservedObject var viewModel: chatViewModel
    @Binding var selectedGroup: Int
    @ObservedObject var groupsViewModel: groupsViewModel
    @State private var chatMessage: String = "" // State variable to hold the chat message
    
    @Binding var timeFrame: String
    
    //@State private var isChatsLoaded: Bool = false
    
    

    var body: some View {
        

        VStack {
            if viewModel.isChatsLoaded {
                HStack {
                    
                    HStack() {
                        TextField("Enter your message", text: $chatMessage)
                        .foregroundColor(.white)
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .keyboardType(.default)
                        .submitLabel(.send) // setting the return key to "send"
                        .onSubmit { // submit action
                            submitMessage()
                        }

                    }
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .cornerRadius(15)
                    

                    Button(action: {
                        submitMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                }

                ScrollView {
                    ForEach(0..<viewModel.allChats.count, id: \.self) { index in
                        chatCellView(viewModel: viewModel, message: viewModel.allChats[index])
                        
                    }
                    
                }.frame(height: 400)
                    .background(K.finalColor.cardBlue)
                    .cornerRadius(10)
                    //.scrollPosition(initialAnchor: .bottom)
                    
            }
            
            
        }.padding([.horizontal, .top])
        .onAppear() {
            viewModel.getChats(groupID: timeFrame == "weekly" ? StaticUserData.shared.weeklyTicket.groupID : StaticUserData.shared.dailyTicket.groupID) {_ in
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mma"
        }
    }

    
    func submitMessage() {
        if !chatMessage.isEmpty {
            viewModel.uploadChat(message: chatMessage, groupID: timeFrame == "weekly" ? StaticUserData.shared.weeklyTicket.groupID : StaticUserData.shared.dailyTicket.groupID)
            chatMessage = "" // clear the text field
            hideKeyboard() // hide keyboard
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct chatCellView: View {
    @ObservedObject var viewModel: chatViewModel
    @State private var flagged = false
    @State var isPresented = false
    var message: Message
 
    @State private var isFocused: Bool = false
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("\(message.username)").padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                    .font(.custom(K.customFonts.poppinsMedium, size: 8))
                    .foregroundColor(K.finalColor.textWhite)
                
                
                Text("\(message.messageContent)")
                    .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                    .font(.custom(K.customFonts.poppinsMedium, size: 15))
                    .foregroundColor(K.finalColor.textWhite)
                //                                    .background(K.veryLightBlue)
                    .cornerRadius(5)
                
            }.padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
            
        Spacer()
            VStack(alignment: .trailing) {
                if !flagged {
                    Button(action: {
                        isPresented.toggle()
                        flagged.toggle()
                    }) {
                        Image(systemName: "flag")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.white)
                            .padding(.trailing,5)
                    }
                } else {
                    Image(systemName: "flag.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.white)
                        .padding(.trailing,5)
                }
                Text("\(formatDateMMMDHMM.format(date: message.timeSent))").font(.custom(K.customFonts.poppinsMedium, size: 8))
                    .foregroundColor(K.finalColor.textWhite)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))
            }
        }
        .sheet(isPresented: $isPresented, content: {
            reportComment(viewModel: viewModel, comment: message, isFocused: $isFocused)
                .presentationDetents([isFocused ? .fraction(0.75) : .fraction(0.40)])
                
        })
        
        
    }
}



struct reportComment: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: chatViewModel
    @State private var reportReason = ""
    var comment: Message
    @Binding var isFocused: Bool

    var body: some View {
        VStack {

            Text("Report Comment")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 24).weight(.medium))
                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                .padding(.top)
            HStack() {
                TextField("", text: $reportReason, axis: .vertical)
                    .placeholder(when: reportReason.isEmpty, placeholder: {
                        Text("What is your reason...").foregroundColor(.gray)
                    })
                    .lineLimit(3, reservesSpace: true)
                    .foregroundColor(.white)
                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                    .accentColor(.white)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .submitLabel(.done)
                    .onTapGesture {
                        withAnimation{
                            isFocused = true
                        }
                    }
                    .onSubmit {
                        withAnimation {
                            isFocused = false
                        }
                    }

            }
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100)
            .cornerRadius(15)
            .padding(.horizontal,16)

            Button(action: {
                viewModel.reportComment(comment: comment, reason: reportReason)
                withAnimation {
                    dismiss()
                }

            }) {
                HStack{
                    Spacer()

                    Text("Update")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    //shadow

                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.horizontal,16)
                    .padding(.bottom,30)

            }
            .padding()

            Spacer()
        }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}


struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
