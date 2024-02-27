//
//  challengeDetails.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/17/24.
//

import SwiftUI

struct challengeDescription: View {
    
//    @ObservedObject var viewModel: pendingChallengeViewModel
    
    var body: some View {
        ZStack {
            VStack {
    
                ScrollView {
                    K.finalColor.backgroundBlue
                    VStack (spacing: 5) {
                        Text("What are Challenges?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("Challenges are a new and innovative way to compete against friends. So, how do they work? ")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Text("1. To start, click create a challenge.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                                                
                        Text("2. Choose the amount you would like to wager with the challenge. Every wager is -105.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        
                        Image("CD1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("3. Choose your opponent. You do this by searching up his username.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("4. Choose the number of empty bets you would like to fill.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("5. Choose the games that you and your opponent will have access to in order to fill your bets.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD4")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("6. Place your bets and fill your challenge ticket. You can choose between spreads/overs for the games you selected. You then have the opportunity to choose alternate lines.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Image("CD6")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("7. Confirm and send to your opponent. He will have 5 minutes to accept or the challenge will be deleted.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD7")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        
                        
                        Text("8. Wait for your bets to complete. When all of the games have completed and the totals have been tallied then the winner will receive their winnings. If both players end up with the same total from their bets then the challenge will PUSH and both players will have their original wager amounts returned to them.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("CD8")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("** To avoid confusing, please remember that the ORIGINAL WAGER (at -105) has nothing to do with the alternate odds selected for your challenge bets. They are unrelated. If the sum of your completed bets is greater than that of your opponent's, you win the challenge. That's it. If you have any questions don't hesitate to DM @WagerPool on instagram.**")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.potentialOrange)
                            .padding()
                        
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct currencyDescription: View {
    var body: some View {
        VStack {
            ScrollView {
                K.finalColor.backgroundBlue
                VStack (spacing: 5) {
                    HStack {
                        Spacer()
                        Image("poolBuck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20) 
                        Text("What are PoolBucks?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        Image("poolBuck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                        Spacer()
                    }
         
                    Text("PoolBucks are WagerPool's in game currency! They are redeemable 1:1 for USD and can be thought of as such. You can win PoolBucks by:")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                    Text("1. Placing in either the Daily or Weekly Global Groups.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    Text("2. Winning a challenge against a friend.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    Text("3. If someone uses your username as their promo code when they sign up, you will receive 2 poolBucks.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                }
            }
        }.padding(.horizontal)
    }
}
