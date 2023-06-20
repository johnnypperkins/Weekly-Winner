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
                if viewModel.currUser != nil {
                    tabBarView()
                    
                }
                    else{
                   //. print("Login")
                    authenticationView()
                
                }

            }.environmentObject(viewModel)
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
