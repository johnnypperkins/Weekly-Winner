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
                                    CustomTabBarItem(index: 0, selectedTab: $selectedTab, item: TabItem(title: "Home", selectedIconName: "HomeSelected", deselectedIconName: "HomeDeselected"))
                                }
                                //.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(0)
                            //.background(K.veryLightBlue.opacity(0.5))
                            BettingAppView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 1, selectedTab: $selectedTab, item: TabItem(title: "Bets",selectedIconName: "HomeSelected", deselectedIconName: "HomeDeselected"))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(1)
                            
                            
                            ticketView(username: "", uid: Auth.auth().currentUser!.uid, groupID: "")
                                .ignoresSafeArea(.all)
                                //.padding(.top)
                                .tabItem {
                                    CustomTabBarItem(index: 2, selectedTab: $selectedTab, item: TabItem(title: "Tickets",selectedIconName: "HomeSelected", deselectedIconName: "HomeDeselected"))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(2)
                            
                            groupsView()
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 3, selectedTab: $selectedTab, item: TabItem(title: "Groups",selectedIconName: "HomeSelected", deselectedIconName: "HomeDeselected"))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(3)
                            
                            profileView(user: authViewModel.currUser!)
                                .ignoresSafeArea(.all)
                                .tabItem {
                                    CustomTabBarItem(index: 4, selectedTab: $selectedTab, item: TabItem(title: "Profile",selectedIconName: "HomeSelected", deselectedIconName: "HomeDeselected"))
                                }//.toolbarBackground(K.finalColor.backgroundBlue, for: .tabBar)
                                                .tag(4)
                        }
                        else {
                            EmptyView()
                        }
                    }.onAppear() {

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
    let selectedIconName: String
    var selectedIcon: Image {
        Image(selectedIconName)
    }
    let deselectedIconName: String
    var deselectedIcon: Image {
        Image(deselectedIconName)
    }
    //let color: Color
}

struct CustomTabBarItem: View {
    let index: Int
    @Binding var selectedTab: Int
    let item: TabItem
    
    var body: some View {
        VStack {
            if index == selectedTab {
                item.selectedIcon
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
            } else {
                item.deselectedIcon
                    .frame(width: 30, height: 30)
                    .cornerRadius(5)
            }
            
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
