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
    case challenges
}

struct tabBarView: View {
    @State private var selectedTab = 0 // which tab selected
    @StateObject var authViewModel = authenticationViewModel()
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
                                .tag(Tab.dashboard)
                            
                            BettingAppView()
                                .background(K.finalColor.backgroundBlue)
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 1, selectedTab: $selectedTab, item: TabItem(title: "Book", icon: Image(systemName: "dollarsign.circle.fill"), color: .green)) // change to book
                                }.tag(Tab.book)
                            
                            
            
                            
                            groupsView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 2, selectedTab: $selectedTab, item: TabItem(title: "Rankings", icon: Image(systemName: "person.3.fill"), color: .purple)) // 
                                }.tag(Tab.groups)
                            
                            challengeView()
                                .background(K.finalColor.cardBlue )
                                .ignoresSafeArea(.all)
                                .navigationBarHidden(true)
                                .tabItem {
                                    CustomTabBarItem(index: 3, selectedTab: $selectedTab, item: TabItem(title: "P2P", icon: Image(systemName: "person.line.dotted.person.fill"), color: .orange))
                                }.tag(Tab.challenges)
                            
                            
                            profileView(user: user)
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 4, selectedTab: $selectedTab, item: TabItem(title: "Profile", icon: Image(systemName: "ticket.fill"), color: .blue))
                                }.tag(Tab.profile)
                            
                        }
                        else {
                            EmptyView()
                        }
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
