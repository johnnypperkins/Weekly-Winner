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
                                .tabItem {
                                    Image(systemName: "1.square.fill")
                                    Text("Tab 1")
                                }
                            //.background(K.veryLightBlue.opacity(0.5))
                            BettingAppView()
                                .tabItem {
                                    Image(systemName: "2.square.fill")
                                    Text("Tab 2")
                                }
                            
                            
                            ticketView(username: "", uid: Auth.auth().currentUser!.uid, groupID: "")
                                .tabItem {
                                    Image(systemName: "3.square.fill")
                                    Text("Tab 3")
                                }
                            
                            groupsView()
                                .tabItem {
                                    Image(systemName: "4.square.fill")
                                    Text("Tab 4")
                                }
                            
                            profileView(user: authViewModel.currUser!)
                                .tabItem {
                                    Image(systemName: "5.square.fill")
                                    Text("Tab 5")
                                }
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

struct tabBarView_Previews: PreviewProvider {
    static var previews: some View {
        tabBarView()
    }
}
