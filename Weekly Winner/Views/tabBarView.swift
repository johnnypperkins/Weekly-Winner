//
//  tabBarView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase

enum Tab {
    case dashboard
    case book
    case ticket
    case groups
    case profile
}

struct tabBarView: View {
    @State private var selectedTab = 0 // which tab selected
    @ObservedObject var authViewModel = authenticationViewModel()
    @State var showContentView = false
    @State private var isShowing = false
    @State var selection: Tab
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing: 0) {
                    //Spacer()
                    
                    TabView (selection: $selection){
                        if let user = authViewModel.currUser {// the corresponding views go under this. Makes sense - Reid
                            UserProfileView(tab: $selection)
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 0, selectedTab: $selectedTab, item: TabItem(title: "Home", icon: Image(systemName: "house.fill"), color: .red))                                }
                                //.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                .tag(Tab.dashboard)
                            //.background(K.veryLightBlue.opacity(0.5))
                            BettingAppView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 1, selectedTab: $selectedTab, item: TabItem(title: "Bets", icon: Image(systemName: "dollarsign.circle.fill"), color: .green))
                                    
                                }.tag(Tab.book)
                            
                            
                            ticketView(username: "", uid: Auth.auth().currentUser!.uid, groupID: "", selectedWeek: "current", ticketFormatForGroups: [], ownTicket: true, onTicketPage: true, passedTimeFrame: "daily")
                                .ignoresSafeArea(.all)
                                //.padding(.top)
                                .tabItem {
                                    CustomTabBarItem(index: 2, selectedTab: $selectedTab, item: TabItem(title: "Tickets", icon: Image(systemName: "ticket.fill"), color: .blue))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(Tab.ticket)
                            
                            groupsView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 3, selectedTab: $selectedTab, item: TabItem(title: "Standings", icon: Image(systemName: "person.3.fill"), color: .purple))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(Tab.groups)
                            
                            //profileView(user: authViewModel.currUser!)
                            challengeView()
                                .background(K.finalColor.cardBlue )
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 4, selectedTab: $selectedTab, item: TabItem(title: "Profile", icon: Image(systemName: "person.crop.circle.fill"), color: .orange))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(Tab.profile)
                        }
                        else {
                            EmptyView()
                        }
                    }.onAppear() {
                        print(authViewModel.currUser)
                    }
                    //.edgesIgnoringSafeArea(.all)

                }
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $showContentView) {
                    ContentView()
                }
            }
        }//.edgesIgnoringSafeArea(.all)
    }
}

struct TabItem {
    let title: String
    let icon: Image
    let color: Color
}

struct CustomTabBarItem: View {
    let index: Int
    @Binding var selectedTab: Int
    let item: TabItem

    var body: some View {
        VStack {
            item.icon
                .frame(width: 30, height: 30)
                .cornerRadius(5)
            Text(item.title)
                //.font(Font.custom("Lexend Deca", size: 9.54).weight(.light))
                .foregroundColor(selectedTab == index ? item.color : .white)
        }
        .padding(EdgeInsets(top: 3.08, leading: 20.66, bottom: 2.63, trailing: 20.90))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            selectedTab = index
        }
    }
}

struct tabBarView_Previews: PreviewProvider {
    static var previews: some View {
        tabBarView(selection: .dashboard)
    }
}
