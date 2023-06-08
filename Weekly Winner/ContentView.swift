//
//  ContentView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = authenticationViewModel()
    var body: some View {
        NavigationStack{
            VStack {
                switch viewModel.authenticationState {
                case .unauthenticated, .authenticating:
                
                    authenticationView()
                    
                case .authenticated:
                   //. print("Login")
                    tabBarView()
                
                }

            }.environmentObject(viewModel)
            .padding()
            .ignoresSafeArea(.all)
        }.ignoresSafeArea(.all)
            .navigationBarBackButtonHidden()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
