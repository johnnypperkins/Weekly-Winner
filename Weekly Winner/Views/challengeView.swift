//
//  challengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

import Foundation
import SwiftUI

struct challengeView: View {
    @State var tabSelected = 0
    
    @ObservedObject var challengeVM = challengeViewModel()
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Available"
        case 1: return "Pending"
        case 2: return "Completed"
        default: return "PoolCoins"
        }
    }

    private func offsetForSelectedTab() -> CGFloat {
        let baseOffset: CGFloat = -212.5
        let tabWidth: CGFloat = 85
        let offset = baseOffset + CGFloat(tabSelected + 1) * tabWidth
        return offset
    }

    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue
            VStack {
                VStack (spacing: 4) {
                    HStack (spacing: 0) {
                        ForEach(0..<4, id: \.self) { index in
                            Button(action: {
                                tabSelected = index
                            }) {
                                Text(tabTitle(for: index))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                    .foregroundColor(.white)
                                    .frame(width: 85, height: 35, alignment: .center)
                                    .cornerRadius(5)
                            }
                        }
                    }.padding(.top, 35)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 75, height: 3)
                        .cornerRadius(1)
                        .offset(x: offsetForSelectedTab(), y: 0)
                        .animation(.easeInOut(duration: 0.35))
                }.padding(.top, 40)
                 .cornerRadius(7.5)
                
                challengeCardView(viewModel: challengeVM)
                    .padding(.top, 20)
                
                Spacer()
            }.background(K.finalColor.backgroundBlue)
        }
    }

 
}




struct challengeCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: {challengePage1(viewModel: viewModel)}, label: {
                    Text("Create a challenge +")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                        .foregroundColor(.white)
                })
            }
        }
        .frame(width: 250, height: 150)
        .background(K.finalColor.cardBlue)
        .cornerRadius(7.5)
    }
}

struct challengePage1: View {
    @State var currencyChosen = "PoolBucks"
    @State var wagerAmount = 0
    @State var opponentUsername = ""
    
    @ObservedObject var viewModel: challengeViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue
                VStack {
                    
                    HStack (spacing: 20){
                        Button(action: {
                            if currencyChosen != "PoolBucks" {
                                currencyChosen = "PoolBucks"
                            }
                        }) {
                            HStack {
                                Text("PoolBucks")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "PoolBucks" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                        Button(action: {
                            if currencyChosen != "PoolCoins" {
                                currencyChosen = "PoolCoins"
                            }
                        }) {
                            HStack {
                                Text("PoolCoins")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "PoolCoins" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                    }.padding(.top, 50)
                    
                    HStack (spacing: 10){
                        TextField("Search Username", text: $opponentUsername)
                            .frame(width: 150)
                            
                        Text((viewModel.opponentUsernameExists && opponentUsername != "") ? "Available" : "Unavailable")
                            .foregroundColor((viewModel.opponentUsernameExists && opponentUsername != "") ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                            .padding(4)
                            .background((viewModel.opponentUsernameExists && opponentUsername != "") ? K.finalColor.winningGreen.opacity(0.6) : K.finalColor.deleteRed.opacity(0.6))
                    }.padding(.top, 10)
                    .onChange(of: opponentUsername) { newValue in
                            viewModel.checkUsernameAvailable(username: newValue) {}
                    }
                    
                    Spacer()
                }
            }
        }.background(K.finalColor.backgroundBlue)
    }
}
