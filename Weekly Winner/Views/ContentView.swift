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
                if viewModel.userSession != nil { // changing from currUser to userSession bc immediate - Reid
//                    tabBarView()
                    SignupIntro()

                }
                    else{
//                   . print("Login")
                authenticationView()
                }

            }            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .environmentObject(viewModel)
            .ignoresSafeArea(.all)
        }            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .navigationBarBackButtonHidden()

            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
