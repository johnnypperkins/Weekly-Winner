//
//  inActionChallengeView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 1/21/24.
//

import SwiftUI
import FirebaseAuth
import Kingfisher

struct inActionChallengeView: View {
    var challenge: ChallengeTicket
    @ObservedObject var viewModel: inActionChallengeViewModel
    
    @State var shouldNavigate = false
    
    @State var profileImageURL: String = ""
    
    @State var opponentChallengeTicket: ChallengeTicket?
    
    @State var loaded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack{
                    Image(challenge.currencyChosen == "poolCoins" ? "poolCoin" : "poolBuck")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    Text(String(format: "%.2f", challenge.wagerAmount))
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 50))
                        .foregroundColor(.white)
                }
                VStack{
                    if loaded == true{
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 0.5)
                                .shadow(radius: 2)
                            
                            VStack {
                                HStack(alignment: .top, spacing: 10) {
                                    
                                    HStack (alignment: .center) {
                                        Text(String(format: "%.0f", opponentChallengeTicket?.totalPotentialWon ?? 0))
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                            .foregroundColor(K.finalColor.potentialOrange)
                                            .frame(width: 60, height: 25, alignment: .center)
                                    }
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                    .background(K.finalColor.potentialOrange.opacity(0.1))
                                    .cornerRadius(5)
                                    
                                    HStack (alignment: .center) {
                                        Text(String(format: "%.0f", opponentChallengeTicket?.totalWon ?? 0))
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                            .foregroundColor((opponentChallengeTicket?.totalWon ?? 0) >= 0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                            .frame(width: 60 , height: 25, alignment: .center)
                                    }
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                    .background(K.finalColor.winningGreen.opacity(0.1))
                                    .cornerRadius(5)
                                    .padding(.trailing, 0)
                                    
                                    Text("\(opponentChallengeTicket?.username ?? "")")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 25))
                                        .foregroundStyle(.white)
                                    
                                    if viewModel.opponentProfilePicURL != "" {
                                        KFImage(URL(string: viewModel.opponentProfilePicURL))
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                    }
                                }.padding(.top, 15)
                                
                                challengeOpponentBetsDisplayAccept(uid: StaticUserData.shared.currentUser.id! == opponentChallengeTicket!.challengerID ? opponentChallengeTicket!.receiverIDs[0] : opponentChallengeTicket!.challengerID, viewModel: viewModel).padding(1)
                            }
                        }.padding()
                    }
          
                    Text("VS")
                        .foregroundStyle(.white)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 30))

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 0.5)
                            .shadow(radius: 2)
                        
                        VStack {
                            HStack {
                                if StaticUserData.shared.currentUser.profileImageUrl != "" {
                                    KFImage(URL(string: StaticUserData.shared.currentUser.profileImageUrl))
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                }
                                Text("\(StaticUserData.shared.currentUser.username)")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 25))
                                    .foregroundStyle(.white)
                                
                                
                                HStack (alignment: .center) {
                                    Text(String(format: "%.0f", challenge.totalWon))
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(challenge.totalWon >= 0 ? K.finalColor.winningGreen : K.finalColor.deleteRed)
                                        .frame(width: 60 , height: 25, alignment: .center)
                                }
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .background(K.finalColor.winningGreen.opacity(0.1))
                                .cornerRadius(5)
                                .padding(.trailing, 0)
                                
                                HStack (alignment: .center) {
                                    Text(String(format: "%.0f", challenge.totalPotentialWon))
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(K.finalColor.potentialOrange)
                                        .frame(width: 60, height: 25, alignment: .center)
                                }
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .background(K.finalColor.potentialOrange.opacity(0.1))
                                .cornerRadius(5)
                            }.padding(.top, 15)
                            
                            challengeBetsDisplayAccept(uid: StaticUserData.shared.currentUser.id!, viewModel: viewModel).padding(1)
                        }
                    }.padding()
                    Spacer()

                }
            }.background(K.finalColor.backgroundBlue)
                //.padding(.bottom, 20)
            
        }.frame(minWidth: 0, maxWidth: .infinity)
        .background(K.finalColor.backgroundBlue)
        .onAppear {
            viewModel.fetchChallengeTicket(by: challenge.customID, uid: StaticUserData.shared.currentUser.id == challenge.challengerID ? challenge.receiverIDs[0] : challenge.challengerID) { challenge in
            opponentChallengeTicket = challenge
            loaded = true
        }
    }
}

struct challengeBetsDisplayAccept: View {
    let uid: String
    @ObservedObject var viewModel: inActionChallengeViewModel

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    ForEach(0..<viewModel.selfTotalBetArrays.count, id: \.self) { parlayIndex in
                        if viewModel.challenge.ticketFormat.count > 0 && viewModel.selfTotalBetArrays.count == viewModel.challenge.ticketFormat.count {
                            SectionTitleAccept(title: parlayTitle(ticketFormat: viewModel.challenge.ticketFormat, index: parlayIndex), betArray: viewModel.selfTotalBetArrays[parlayIndex], maxBetsPlaced: viewModel.challenge.ticketFormat[parlayIndex], uid: StaticUserData.shared.currentUser.id ?? "", viewModel: viewModel)
                        }
                    }
                }
            }.padding(.bottom,15)
                .padding(.horizontal)
        }.frame(height: 150)
    }
}
    
    struct challengeOpponentBetsDisplayAccept: View {
        let uid: String
        @ObservedObject var viewModel: inActionChallengeViewModel

        var body: some View {
            
            ScrollView {
                VStack {
                    VStack {
                        ForEach(0..<viewModel.opponentTotalBetArrays.count, id: \.self) { parlayIndex in
                            if viewModel.challenge.ticketFormat.count > 0 && viewModel.opponentTotalBetArrays.count == viewModel.challenge.ticketFormat.count {
                                SectionTitleAccept(title: parlayTitle(ticketFormat: viewModel.challenge.ticketFormat, index: parlayIndex), betArray: viewModel.opponentTotalBetArrays[parlayIndex], maxBetsPlaced: viewModel.challenge.ticketFormat[parlayIndex], uid: uid, viewModel: viewModel)
                            }
                        }
                    }
                }.padding(.bottom,15)
                    .padding(.horizontal)
            }.frame(height: 150)
        }
    }

    struct SectionTitleAccept: View {
        let title: String
        let betArray: [Bet]
        let maxBetsPlaced: Int
        let uid: String
        @ObservedObject var viewModel: inActionChallengeViewModel
        @State var expand = false
        
        
        var totalOdds: Double {
            var total: Double = 1
            for bet in betArray {
                total = total*Double(bet.betOdds)
            }
            return total
        }
        
        var hasLoss: Bool {
            return betArray.contains(where: { $0.result == .loss })
        }
        
        var statusColor: Color {
            if betArray.contains(where: { $0.result == .loss }) {
                return K.finalColor.deleteRed
            } else {
                if betArray.count != maxBetsPlaced && (betArray.contains(where: { $0.result == .inAction }) || betArray.contains(where: { $0.result == .win })) {
                    return K.finalColor.cardBlue
                } else if betArray.count == maxBetsPlaced && (betArray.contains(where: { $0.result == .inAction }) || betArray.contains(where: { $0.result == .notStarted})) {
                    return K.finalColor.cardBlue
                } else if betArray.count == maxBetsPlaced  {
                    return K.finalColor.winningGreen
                } else {
                    return K.finalColor.cardBlue
                }
            }
        }
        
        var body: some View {
            ZStack {
                VStack (alignment: .leading) {
                    HStack() {
                        
                        Text("\(title) | \(percentageToTotalWin(percentage: totalOdds))")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                    }
                    .frame(height: 5)
                    .padding(.top, 10)
                    Rectangle()
                        .frame(height: 0.75)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 2, trailing: 0))
                        .foregroundColor(K.finalColor.textWhite.opacity(0.9))
                    
                    VStack(alignment: .center) {
                        let emptyBoxesCount = max(0, maxBetsPlaced - betArray.count)
                        let totalBetsCount = betArray.count + emptyBoxesCount
                        
                        ForEach(0..<totalBetsCount, id: \.self) { index in
                            VStack(alignment: .center, spacing: 0) {
                                if index < betArray.count {
                                    BetCard(bet: betArray[index], uid: uid, viewModel: viewModel)
                                    
                                } else {
                                    EmptyBetCard(betArray: betArray)
                                }
                                if index != totalBetsCount - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    
                    //.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .frame(width: 311) // Removed the height: 35 constraint
                    .background(.clear)
                    //.cornerRadius(10)
                    .padding(.bottom, 5)
                }
                .frame(width: 320)
            }
            .frame(width: 343)
            .background(statusColor.opacity(0.65))
            .cornerRadius(10)
            
        }
        
        struct BetCard: View {
            
            let bet: Bet
            let uid: String
            @State private var canDelete: Bool = false
            @State var moreInfoClicked = false
            @ObservedObject var viewModel: inActionChallengeViewModel
            @State private var game: Game? = nil
            @State var expand = false
            
            //let ownBets: Bool
            
            
            var extra: String {
                if bet.betType == .under {
                    return "u"
                } else if bet.betType == .over {
                    return "o"
                } else {
                    if bet.betLine >= 0 {
                        return "+"
                    }
                }
                return ""
            }
            
            var lineFinal: String {
                if bet.betLine == 0 {
                    return "ML"
                } else {
                    let roundedBetLine = round(bet.betLine)
                    return "\(extra)\(Int(roundedBetLine))"
                }
            }
            
            
            var body: some View {
                //HStack {
                
                HStack {
                    VStack (spacing: 0){
                        HStack (spacing: 0) {
                            if bet.result == .forcedLoss {
                                Text("-")
                            } else {
                                //Spacer()
                                Text(percentageToML(percentage: Double(bet.betOdds)))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))
                                //.background(Color.backgroundForBetResult(bet.result))
                                //.background(K.gra)
                                //.cornerRadius(7.5)
                                Rectangle()
                                    .fill(Color.white) // Color of the separator
                                    .frame(width: 1, height: 20) // Adjust height as needed
                                //Spacer()
                                Text("\(bet.teamBetOn ?? "Null Team") \(lineFinal)")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size:
                                                    bet.teamBetOn?.count ?? 10 < 20 ? 16 : 13))
                                //   (bet.teamBetOn?.count ?? 10 > 35 ? 9: 11)))
                                
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5))
                                    .cornerRadius(7.5)
                                    .frame(maxWidth: 250, alignment: .leading)
                                
                                Button {
                                    withAnimation {
                                        expand.toggle()
                                    }
                                } label: {
                                    if expand {
                                        Image(systemName: "chevron.down")
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.white)
                                            .frame(width: 30, height: 24)
                                        //.background()
                                    }
                                    else{
                                        Image(systemName: "chevron.up")
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.white)
                                            .frame(width: 30, height: 24)
                                    }
                                }
                            }
                        }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(bet.result == .notStarted ? K.finalColor.backgroundBlue : Color.backgroundForBetResult(bet.result))
                        if expand {
                            HStack {
                                VStack (spacing: 3){
                                    if bet.result == .notStarted {
                                        Rectangle()
                                            .fill(Color.white) // Color of the separator
                                            .frame(width: bet.result == .notStarted ? 240 : 300 , height: 1) // Adjust height as needed
                                    }
                                    HStack {
                                        VStack {
                                            HStack {
                                                Text("\(game?.homeTeam ?? "")")
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                            HStack(spacing: 0) {
                                                Text("\(game?.awayTeam ?? "")")
                                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                        }.frame(width: 220)
                                            .padding(.leading)
                                        Spacer()
                                        VStack {
                                            Text((game?.homeTeamScore ?? -1) >= 0 ? "\(game?.homeTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 30)
                                            Text((game?.awayTeamScore ?? -1) >= 0 ? "\(game?.awayTeamScore ?? -1)" : "")
                                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 30)
                                        }.padding(.trailing)
                                        
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("\(game?.whichSport ?? "") | \(formatDateEMMMDHMM.format(date: game?.commenceTime.dateValue() ?? Date()))")
                                            .font(.custom(K.customFonts.lexendDecaMedium, size: 10))
                                            .foregroundColor(K.finalColor.textWhite)
                                        //.frame(maxWidth: .infinity, alignment: .center)
                                        Spacer()
                                    }
                                }
                                
                            }.padding(EdgeInsets(top: 5, leading: 7.5, bottom: 5, trailing: 0))
                                .background(K.finalColor.backgroundBlue)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity) // This line
                    
                        .cornerRadius(7.5)
                    
                    //                if bet.result == .notStarted && uid == Auth.auth().currentUser?.uid && viewModel.canDeleteBets{ // ONLY SHOWS DELETE BUTTON IF .NOTSTARTED
                    //                    Button(action: {
                    //                        viewModel.deleteChallengeBet(bet: bet)
                    //                    }) {
                    //                        Image(systemName: "xmark.circle")
                    //                            .resizable()
                    //                            .frame(width: 20, height: 20)
                    //                            .foregroundColor(canDelete ? .red : .red.opacity(0.5))
                    //
                    //                    }
                    //                }
                }.background(bet.result == .notStarted ? Color.clear : Color.backgroundForBetResult(bet.result))
                    .cornerRadius(7.5)
                    .frame(width: 320)
                    .onAppear() {
                        canDelete = false
                        
                        viewModel.fetchGameDocument(byID: bet.gameID) { fetchedGame in
                            if let fetchedGame = fetchedGame {
                                print("Fetched game: \(fetchedGame)")
                                self.game = fetchedGame
                            } else {
                                print("Failed to fetch game")
                                // Handle the error or absence of the game
                            }
                        }
                        
                    }
                    .onDisappear() {
                        expand = false
                    }
            }
        }
        
    }
    
    struct EmptyBetCard: View {
        var betArray: [Bet]
        var body: some View {
            if betArray.contains(where: { $0.result.rawValue == "loss" }) {
                Rectangle()
                    .fill(K.finalColor.deleteRed)
                    .frame(width: 320, height: 35)
                    .overlay(
                        Text("Forced Loss")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                    ).cornerRadius(7.5)
                
            } else {
                Rectangle()
                    .fill(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .frame(width: 291, height: 30)
                    .overlay(
                        Text("Empty Bet")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                    ).cornerRadius(5)
            }
        }
    }
    
}


//#Preview {
//    inActionChallengeView()
//}
