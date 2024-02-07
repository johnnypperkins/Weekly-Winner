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
                        Text("How To Challenge?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("     A challenge is a new way to wager against friends to see who is the best at choosing winning teams.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Text("To start, click create a challenge.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
//                        Image("chalHowTo1")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 320)
//                            .cornerRadius(5)
//                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Then, pick your opponent and set your wager!")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("chalHowTo1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Choose your favorite games to bet on.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("chalHowTo2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Select your custom picks to wager against your friend.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("chalHowTo3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("Finalize your challenge and send it to your friend.")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("chalHowTo4")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        Text("You can then see your challenges on the pending page")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding()
                        
                        Image("chalHowTo5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        
                        
                        
                        Text("When the last game ends in the challenge, the winning player will be rewarded the WagerBucks!")
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
