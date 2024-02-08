//
//  globalPrizesView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/20/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase
import Kingfisher
import SafariServices

struct globalPrizesView: View {
    @State var time: String
    
    @ObservedObject private var viewModel: prizesViewModel
    
    init(time: String, viewModel: prizesViewModel) {
        self.time = time
        self.viewModel = viewModel
    }
    
    let prizeSize: CGFloat = 25
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                       
                        Text(time == "daily" ? "DAILY GLOBAL PRIZES" : "WEEKLY GLOBAL PRIZES")
                            .foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                            .padding(.bottom)
                        Spacer()
                    }
                    HStack (alignment: .center){
                        VStack (alignment: .leading, spacing: 10){
                            
                            Text("1st Place: ")
                               .foregroundColor(.white)
                               .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                            
                            
                                Text("2nd Place: ")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                  
                            
                                Text("3rd Place: ")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                 
                            
                                Text("4th Place: ")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                    
                            
                                Text("5th Place: ")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                        
                        }
                        if viewModel.canViewPrizes {
                            if time != "daily"{
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.prizes[0])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                 
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.prizes[1])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    
                                    
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.prizes[2])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.prizes[3])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                   
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.prizes[4])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                               
                                }
                            }
                            else {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.dailyPrizes[0])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.dailyPrizes[1])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.dailyPrizes[2])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.dailyPrizes[3])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                    HStack (spacing: 4) {
                                        Image("poolBuck")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                        Text("\(viewModel.dailyPrizes[4])")
                                            .foregroundColor(.white)
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: prizeSize))
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    HStack {
                        Spacer()
                        Text("Your funds will be credited to your account!")
                            .foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .padding(.bottom)
                        Spacer()
                    }.padding(5)
//                        .background(K.finalColor.cardBlue)
                        .cornerRadius(3)
                        .padding(.top)
                }
            }
        }
    }
}

struct statsView: View {
    @StateObject private var viewModel = statsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Text("Bet Score Leaderboard")
                            .foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                        Spacer()
                    }
                    Rectangle()
                        .fill(Color.white) // Color of the separator
                        .frame(width: 285 , height: 1) // Adjust height as needed
                        .padding(.bottom, 5)
                    VStack {
                        ForEach(viewModel.top10players.indices, id: \.self) { index in
                            HStack {
                                HStack {
                                    Text("\(index + 1).")
                                        .foregroundColor(.white)
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                                }.frame(width: 22.5)
                                if viewModel.top10players[index].profileImageUrl != "" {
                                    KFImage(URL(string: viewModel.top10players[index].profileImageUrl))
                                        .resizable()
                                        .clipShape(Circle())
                                        .aspectRatio(contentMode: .fill)
                                        .foregroundColor(.clear)
                                        .frame(width: 30, height: 30)
                                }else {
                                    Image(systemName: "photo.circle.fill")
                                        .resizable()
                                        .foregroundColor(K.finalColor.cardBlue)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                }
                                Text("\(viewModel.top10players[index].username)")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                Spacer()
                                Text("\(String(format: "%.1f", viewModel.top10players[index].betScore))")
                                    .foregroundColor(K.finalColor.titleBlue)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                            }
                            
                        }
                    }.frame(width: 275)
                        .padding(.horizontal)
                    
                }
            }
        }
    }
}
