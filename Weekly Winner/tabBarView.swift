//
//  tabBarView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct tabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                                // Action for left button
                            }) {
                                Image(systemName: "gear")
                                    .imageScale(.large)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "bitcoinsign")    // Replace "logo" with your actual logo image asset name
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                            
                            Spacer()
                            
                            Button(action: {
                                // Action for right button
                            }) {
                                Image(systemName: "bell")
                                    .imageScale(.large)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        
                        Spacer()
                        
                        TabView {
                            UserProfileView()
                                .tabItem {
                                    Image(systemName: "1.square.fill")
                                    Text("Tab 1")
                                }
                              
                            
                            BettingAppView()
                                .tabItem {
                                    Image(systemName: "2.square.fill")
                                    Text("Tab 2")
                                }
                              
                            
                            FantasyFootballView()
                                .tabItem {
                                    Image(systemName: "3.square.fill")
                                    Text("Tab 3")
                                }
                                
                            
                            screen4()
                                .tabItem {
                                    Image(systemName: "4.square.fill")
                                    Text("Tab 4")
                                }
                          
                            
                            screen5()
                                .tabItem {
                                    Image(systemName: "5.square.fill")
                                    Text("Tab 5")
                                }
                           
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarBackButtonHidden(true)
        }
    }
}

struct tabBarView_Previews: PreviewProvider {
    static var previews: some View {
        tabBarView()
    }
}
