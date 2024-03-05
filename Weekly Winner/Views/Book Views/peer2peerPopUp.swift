//
//  peer2peerPopUp.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 3/4/24.
//

import Foundation
import SwiftUI

struct peer2peerSubmitPage: View {
    let game: Game
    let betType: BetType
    let viewModel: bookViewModel
    
    var body: some View {
        VStack {
            yourWager(game: game, parlaySize: 1, viewModel: viewModel, betType: betType)
            Spacer()
        }
    }
}


struct yourWager: View {
    let game: Game
    var parlaySize: Int
    var viewModel: bookViewModel
    //var extra: String
    var internalExtra: String {
        switch betType {
        case .betHomeSpread:
            return "+"
        case .betAwaySpread:
            return "+"
        case .betHomeML:
            return "+"
        case .betAwayML:
            return "+"
        case .over:
            return "o"
        case .under:
            return "u"
        default:
            return ""
        }
    }
    
    var spreadExtension: Double {
        print("Parlay size: ", parlaySize)
        if parlaySize == 1 {
            return 15
        } else if parlaySize == 2 {
            return 4
        } else if parlaySize == 3 {
            return 1
        } else if parlaySize == 4 || parlaySize == 5 {
            return -1
        }
        
        return 10
    }
    var step: Int {
        if betType == .over {
            return -1
        } else {
            return 1
        }
    }
    

    var betType: BetType
    
    var teamString: String {
        if betType == .betHomeML || betType == .betHomeSpread {
            return "\(game.homeTeam)"
        } else if betType == .betAwayML || betType == .betAwaySpread {
            return "\(game.awayTeam)"
        } else {
            return "\(game.homeTeam)" + "/" + "\(game.awayTeam)"
        }
    }
    
    var MLString: String {
        if betType == .betHomeML {
            return game.homeML > 0 ? "+\(game.homeML)" : "\(game.homeML)"
        } else if betType == .betAwayML {
            return game.awayML > 0 ? "+\(game.awayML)" : "\(game.awayML)"
        } else if betType == .betHomeSpread {
            return game.homeSpreadODDS > 0 ? "+\(game.homeSpreadODDS)" : "\(game.homeSpreadODDS)"
        } else if betType == .betAwaySpread {
            return game.awaySpreadODDS > 0 ? "+\(game.awaySpreadODDS)" : "\(game.awaySpreadODDS)"
        } else if betType == .over {
            return game.totalOverODDS > 0 ? "+\(game.totalOverODDS)" : "\(game.totalOverODDS)"
        } else if betType == .under {
            return game.totalUnderODDS > 0 ? "+\(game.totalUnderODDS)" : "\(game.totalUnderODDS)"
        } else {
            return ""
        }
    }
    var spreadString: String {
        switch betType {
        case .betHomeSpread:
            return isWholeNumber(game.homeSpread) ? String(format: "%.0f", game.homeSpread) : String(game.homeSpread)
        case .betAwaySpread:
            return isWholeNumber(game.awaySpread) ? String(format: "%.0f", game.awaySpread) : String(game.awaySpread)
        case .over:
            return isWholeNumber(game.totalOver) ? String(format: "%.0f", game.totalOver) : String(game.totalOver)
        case .under:
            return isWholeNumber(game.totalUnder) ? String(format: "%.0f", game.totalUnder) : String(game.totalUnder)
        case .betHomeML:
            return "ML"
        case .betAwayML:
            return "ML"
        case .None:
            return ""
        }
    }
    
    @State private var opponentUsername: String = ""
    @State private var selectedUserID: String = ""
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                opponentUsername.lowercased()
            },
            set: {
                opponentUsername = $0.lowercased()
                viewModel.fetchUser(from: opponentUsername.lowercased())
            }
        )
        
        VStack (spacing: 3){
            searchBarView(keyword: keywordBinding)
                    
            ScrollView {
                ForEach(viewModel.queriedUsers, id: \.id) { user in
                    if user.id != StaticUserData.shared.currentUser.id {
                        userBio(user: user, selectedUserID: $selectedUserID, selectedUserUsername: $opponentUsername)
                            .padding(.vertical,3)
                            .padding(.horizontal,14)
                    }
                }
            }.frame(height: 115)
                .padding(.vertical)
            
            HStack {
                Text("Your Wager")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                    .padding(.leading, 2)
                Spacer()
            }.frame(width: 345)
  
            VStack(spacing: 7.5) {
                HStack(spacing: 7.5) {
                    teamMiniView(teamString: teamString)
                    oddsMiniView(betType: betType, internalExtra: internalExtra, spreadString: spreadString)
                    MLMiniView(MLString: MLString)
                    
                }
                HStack(spacing: 7.5) {
                    riskMiniStruct(game: game, betType: betType, riskAmount: 100.0)
                    rewardMiniStruct(game: game, betType: betType, riskAmount: 125.0)
                }.frame(width: 345)
            }
        }
        
        VStack (spacing: 3){
            HStack {
                Spacer()
                Text("Opponent Wager")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                    .padding(.trailing, 2)
            }.frame(width: 345)
  
            VStack(spacing: 7.5) {
                HStack(spacing: 7.5) {
                    teamMiniView(teamString: teamString)
                    oddsMiniView(betType: betType, internalExtra: internalExtra, spreadString: spreadString)
                    MLMiniView(MLString: MLString)
                    
                }
                HStack(spacing: 7.5) {
                    riskMiniStruct(game: game, betType: betType, riskAmount: 100.0)
                    rewardMiniStruct(game: game, betType: betType, riskAmount: 125.0)
                }.frame(width: 345)
            }
        }.padding(.top, 5)
        
        
    }
}


struct teamMiniView: View {
    let teamString: String
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Team")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Text("\(teamString)")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: teamString.count < 25 ? 16 : 10))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .padding(.leading)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 200).cornerRadius(5)
    }
}

struct oddsMiniView: View {
    let betType: BetType
    let internalExtra: String
    let spreadString: String
 
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(betType == .over || betType == .under ? "Total" : "Spread")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Spacer()
                Text(internalExtra + spreadString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 65).cornerRadius(5)
    }
}

struct MLMiniView: View {
    let MLString: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Odds")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.tabSelectedBlue)
            HStack {
                Spacer()
                Text(MLString)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: MLString.count < 6 ? 16 : 14))
                    .foregroundColor(.white)
                    .lineLimit(3)
                Spacer()
            }.frame(height: 50).background(K.finalColor.cardBlue)
        }.frame(width: 65).cornerRadius(5)

    }
}


struct riskMiniStruct: View {
    let game: Game
    let betType: BetType
    let riskAmount: Double
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Text("Risk")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.deleteRed)
            HStack {
                Spacer()
                Text("$100")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}
struct rewardMiniStruct: View {
    let game: Game
    let betType: BetType
    let riskAmount: Double
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Text("Potential Win")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 15).background(K.finalColor.potentialOrange)
            HStack {
                Spacer()
                Text(percentageToTotalWin(percentage: MLtoPercentage(moneyline: betTypeToOdds(game: game, betType: betType))))
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
            }.frame(height: 41.25).background(K.finalColor.cardBlue)
        }.cornerRadius(7.5)
    }
}
