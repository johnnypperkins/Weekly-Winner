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
            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])
            VStack {
                
                Color.white
                    .opacity(0.2)
                    .frame(width: 30, height: 6)
                    .clipShape(Capsule())
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                
                ScrollView {
                    K.finalColor.backgroundBlue
                    VStack (spacing: 5) {
                        Text("How To Play WagerPool?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("     WagerPool is a FREE TO PLAY social sportsbook where players can place risk free bets in an attempt to win real prizes. ")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Text("To start, go to the Bets page.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Image("howTo1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Then, pick a game.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Choose a spread or total.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Choose the daily or weekly challenge + the corresponding bet you would like to fill.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo4")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Choose your odds and place your bet.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("You can then see your bets on the ticket page.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo6")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("You are ranked against other players for both the daily and weekly challenges. Orange = Pending, Green = Won.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("howTo7")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("When the day/week ends, winning players can receive their prizes by dming @WagerPool on instagram!")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                    }.padding(.horizontal)
                }
            }
        }
    }
}

//#Preview {
//    challengeDetails(challenge: ChallengeTicket(customID: <#T##String#>, username: <#T##String#>, opponentUsername: <#T##String#>, dateCreated: <#T##Timestamp#>, wagerAmount: <#T##Double#>, currencyChosen: <#T##String#>, totalPotentialWon: <#T##Double#>, totalWon: <#T##Double#>, status: <#T##String#>, challengerID: <#T##String#>, receiverIDs: <#T##[String]#>, ticketFormat: <#T##[Int]#>, gameIDs: <#T##[String]#>))
//}
