//
//  tabBarView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase

struct tabBarView: View {
    @State private var selectedTab = 0 // which tab selected
    @ObservedObject var authViewModel = authenticationViewModel()
    @State var showContentView = false
    @State private var isShowing = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(spacing: 0) {
                    //Spacer()
                    
                    TabView {
                        if let user = authViewModel.currUser {// the corresponding views go under this. Makes sense - Reid
                            UserProfileView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 0, selectedTab: $selectedTab, item: TabItem(title: "Home", icon: Image(systemName: "house.fill")))
                                }
                                //.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(0)
                            //.background(K.veryLightBlue.opacity(0.5))
                            BettingAppView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 1, selectedTab: $selectedTab, item: TabItem(title: "Bets", icon: Image(systemName: "dollarsign.circle.fill")))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(1)
                            
                            
                            ticketView(username: "", uid: Auth.auth().currentUser!.uid, groupID: "")
                                .ignoresSafeArea(.all)
                                //.padding(.top)
                                .tabItem {
                                    CustomTabBarItem(index: 2, selectedTab: $selectedTab, item: TabItem(title: "Tickets", icon: Image(systemName: "ticket.fill")))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(2)
                            
                            groupsView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 3, selectedTab: $selectedTab, item: TabItem(title: "Groups", icon: Image(systemName: "person.3.fill")))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(3)
                            
                            profileView(user: authViewModel.currUser!)
                                //.ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 4, selectedTab: $selectedTab, item: TabItem(title: "Profile", icon: Image(systemName: "person.crop.circle.fill")))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(4)
                        }
                        else {
                            EmptyView()
                        }
                    }.onAppear() {
//                        let standardAppearance = UITabBarAppearance()
//                        standardAppearance.backgroundColor = UIColor(K.finalColor.backgroundBlue)
//                                        let itemAppearance = UITabBarItemAppearance()
//                                        itemAppearance.normal.iconColor = UIColor(Color.white)
//                        itemAppearance.selected.iconColor = UIColor(K.finalColor.tabSelectedBlue)
//                        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//                        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.finalUIColor.tabSelectedBlue]
//                                        standardAppearance.inlineLayoutAppearance = itemAppearance
//                                        standardAppearance.stackedLayoutAppearance = itemAppearance
//                                        standardAppearance.compactInlineLayoutAppearance = itemAppearance
//                                        UITabBar.appearance().standardAppearance = standardAppearance
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
    //let color: Color
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
                .font(Font.custom("Lexend Deca", size: 9.54).weight(.light))
        }
        //.padding(EdgeInsets(top: 7, leading: 20.66, bottom: 0, trailing: 20.90))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            selectedTab = index
        }
    }
}

struct tabBarView_Previews: PreviewProvider {
    static var previews: some View {
        tabBarView()
    }
}
