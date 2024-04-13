//
//  ContentView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = authenticationViewModel() // Assuming your view model's name starts with an uppercase letter
    @State private var shouldTransitionToTabBarView = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.userSession != nil {
                    if viewModel.currUser?.username == nil || viewModel.updateURL == nil{
                       // if !shouldTransitionToTabBarView {
                            viewTest()
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        // This will be executed after a delay of 5 seconds
                                        self.shouldTransitionToTabBarView = true
                                    }
                                }
                        //}
                    } else if viewModel.updateURL != "" {
                        updateViewPage()
                    } else if viewModel.currUser?.username == "" {
                        profilePhotoSelectorView(model: viewModel)
                    } else if shouldTransitionToTabBarView {
                        // Transition to tabBarView after the delay
                        tabBarView(selection: .dashboard)
                    }
                } else {
                    authenticationView()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .environmentObject(viewModel)
            .ignoresSafeArea(.all)
        }
        .navigationBarBackButtonHidden()
    }
}

// Ensure your other view structures like viewTest, profilePhotoSelectorView, and tabBarView are correctly defined elsewhere in your code.


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct viewTest: View {
    var body: some View {
        VStack {
            Text("Loading...")
                .font(Font.custom(K.customFonts.lexendDecaSB, size: 30).weight(.semibold))
                .foregroundColor(K.finalColor.titleBlue)
        }
    }
}

struct updateViewPage: View {
    @State var showWebpage = false
    
    var body: some View {
        VStack {
            Button(action: {
                showWebpage = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Click to update WagerPool")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 30).weight(.semibold))
                        .foregroundColor(K.finalColor.titleBlue)
                        .padding()
                    Spacer()
                }.background(K.finalColor.cardBlue).cornerRadius(7.5)
                    .padding(.horizontal)

            })
            
        }
        .sheet(isPresented: $showWebpage) {
            SafariView(url: URL(string: "https://apps.apple.com/us/app/wagerpool/id6461645537")!)
        }
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
