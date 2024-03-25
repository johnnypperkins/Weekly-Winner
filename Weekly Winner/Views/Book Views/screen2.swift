//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import Pow

struct BettingAppView: View {
    @StateObject private var viewModel = bookViewModel()
    @State private var showingSheet = false
    @State private var isShowing = false
    @State private var searchTerm: String = ""
    @State private var poolBucks = StaticUserData.shared.currentUser.poolBucks
    
    @State private var rankedCommence = false
    @State var isOn = true

    func shouldAppear(search: String, input: String) -> Bool {
        return input.lowercased().contains(search.lowercased())
    }
 
    var body: some View {
        ZStack{
            if isShowing {
                sideMenuView(bookVM: viewModel, isShowing: $isShowing)
            }
            VStack {
                
                screen2HeaderView(isShowing: $isShowing, rankedCommence: $rankedCommence, searchTerm: $searchTerm, viewModel: viewModel, poolBucks: $poolBucks)

                ScrollView { // All the games to display
                    VStack(spacing: 5) {
                        // Displaying games
                        if viewModel.allGames != [] {
                            ForEach(rankedCommence ? viewModel.allGames : viewModel.allPopularGames, id: \.idd) { game in
                                if (shouldAppear(search: searchTerm, input: game.homeTeam) || shouldAppear(search: searchTerm, input: game.awayTeam) || searchTerm == "") {
                                    let now = Date() // Get the current date and time
                                    if game.commenceTime.dateValue() > now {
                                        if viewModel.selectedGameType == "All Games" {
                                            gameRowView(game: game, isDisabled: false, viewModel: viewModel, poolBucks: $poolBucks)
                                
                                        } else if viewModel.selectedGameType == game.whichSport {
                                            gameRowView(game: game, isDisabled: false, viewModel: viewModel, poolBucks: $poolBucks)

                                        }
                                    }
                                }
                            }.padding(.horizontal)
                        } else {
                            Text("Games Loading...")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(K.finalColor.textWhite)
                                .padding()
                        }
                        
                    }.padding(.bottom,40)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(K.finalColor.backgroundBlue)
            .cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
        }.background(K.finalColor.backgroundBlue)
            .padding(EdgeInsets(top: 60, leading: 0, bottom: 55, trailing: 0))
            .navigationBarHidden(false)
            .onAppear() {
                rankedCommence = false
            }
            .onDisappear() {
                viewModel.getGamesCommenceTime() {}
            }
//            .onChange(of: showingSheet) { _ in
//                poolBucks = StaticUserData.shared.currentUser.poolBucks
//            }
    }
    
}

struct screen2HeaderView: View {
    @Binding var isShowing: Bool
    @Binding var rankedCommence: Bool
    @Binding var searchTerm: String
    @ObservedObject var viewModel: bookViewModel
    @Binding var poolBucks: Double

    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                currencyView(poolCoins: StaticUserData.shared.currentUser.poolCoins, poolBucks: $poolBucks)
                    .padding(.trailing)
            }
            
            ZStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowing.toggle()
                        }
                        searchTerm = ""
                        rankedCommence = true
                    }, label: {
                        HStack {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding(10) // Add padding around the button
                        .background(K.finalColor.cardBlue) // Set the background color
                        .cornerRadius(5) // Optional: Add a corner radius if you want rounded corners
                    }).padding(.leading)

                    Spacer()
                    
                    

                }
                if viewModel.selectedGameType == "All Games" {
                    Text(rankedCommence ? viewModel.selectedGameType : "Popular Games")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(K.finalColor.textWhite)
                } else {
                    Text(viewModel.selectedGameType)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(K.finalColor.textWhite)
                }
         
                HStack{
                    Spacer()
                }.padding(.trailing)
            }.padding(.top, 3)
            
        }
        
        HStack {
            HStack {
                TextField("Search", text: $searchTerm)
                    .placeholder(when: searchTerm == "", placeholder: {
                        Text("Search for games...").foregroundColor(.gray)
                            .padding(.leading, 2)
                    })
                    .foregroundColor(.white)
                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                    .accentColor(.white)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                //.padding(.vertical, 5)
               
                
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 15))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
            .cornerRadius(7.5)
            .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 10))
            
//            Button(action: {
//                searchTerm = ""
//                rankedCommence.toggle()
//            }, label: {
//                HStack {
//                    Text("\(rankedCommence ? "Upcoming" : "Popular")")
//                        .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
//                        .foregroundStyle(.white)
//                }
//                    .frame(width: 80, height: 40)
//                    .background(K.finalColor.titleBlue)
//                    .cornerRadius(7.5)
//                    .padding(.trailing, 14)
//            })
            Toggle("", isOn: $rankedCommence)
                .toggleStyle(CustomToggleStyle(onColor: K.finalColor.titleBlue, offColor: .red, knobColor: .white))
                    .padding(.trailing, 14)
        }
        HStack{
            Text("Team Name") // team name
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundColor(K.finalColor.textWhite)
                .padding(.leading)
            Spacer()
            HStack(spacing: 0) {
                Text("Spread")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(width: 50, alignment: .center)
                Text("ML")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(width: 45, alignment: .center)
                    .padding(.trailing, 9)
                Text("Total")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 12))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(width: 58, alignment: .center)
                    .padding(.trailing, 9)
            }
            
            Divider()
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
        .padding(.horizontal)
        .overlay(
                Rectangle()
                    .frame(height: 1)
                    //.padding(.top, 100)
                    .padding(.horizontal)
                    .foregroundColor(.white), alignment: .bottom)
    }
}


struct gameRowView: View {
    let game: Game
    let isDisabled: Bool
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betType: BetType = .None
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    @ObservedObject var viewModel: bookViewModel
    @Binding var poolBucks: Double

    
    var maxHeight = 100
    var maxWidth = 100
    
    var body: some View {
      
        HStack {
            VStack(spacing:2) {
                HStack{
                    Text("\(game.homeTeam)") // team name
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    HStack(spacing: 7.5) {
                        PlaceBetButton(game: game, betTypeOfButton: .betHomeSpread, selectedBetType: $betType) { // home spread
                            betType = .betHomeSpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(game: game, betTypeOfButton: .betHomeML, selectedBetType: $betType) { // Home ML
                            betType = .betHomeML
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(game: game, betTypeOfButton: .over, selectedBetType: $betType) { // over
                            betType = .over
                            showingSheet.toggle()
                        }
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                HStack {
                    Text("\(game.awayTeam)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 7.5) {
                        PlaceBetButton(game: game, betTypeOfButton: .betAwaySpread, selectedBetType: $betType) {
                            betType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(game: game, betTypeOfButton: .betAwayML, selectedBetType: $betType) { // Away ML
                            betType = .betAwayML
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(game: game, betTypeOfButton: .under, selectedBetType: $betType) {
                            betType = .under
                            showingSheet.toggle()
                        }
                    }
                }.padding(.top,4)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                Text("\(game.whichSport) | \(formatDateEMMMDHMM.format(date: game.commenceTime.dateValue()))")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 11))
                    .foregroundColor(K.finalColor.textWhite)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }.padding(.horizontal)
            .padding(EdgeInsets(top: 7.5, leading: 0, bottom: 4, trailing: 0))
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        
        .popup(isPresented: $showingSheet) {
            screen2PopUp(game: game, betType: $betType, viewModel: viewModel, showingSheet: $showingSheet, poolBucks: $poolBucks)
                .frame(height: 700)
        } customize: {
            $0
                .type (.toast)
                .position(.bottom)
                .isOpaque(true)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.4))
                .dismissCallback {
                    withAnimation {
                        betType = .None
                    }
                }
        }
    }
}


struct PlaceBetButton: View {
    let game: Game
    let betTypeOfButton: BetType // the
    @Binding var selectedBetType: BetType
    let action: () -> Void
    
    var isDisabled: Bool {
        switch betTypeOfButton {
        case .betHomeSpread:
            return game.homeSpread == -99 || game.homeSpread == 0
        case .betAwaySpread:
            return game.awaySpread == -99 || game.awaySpread == 0
        case .over:
            return game.totalOver == -99
        case .under:
            return game.totalUnder == -99
        case .betHomeML:
            return game.homeML == -99
        case .betAwayML:
            return game.awayML == -99
        case .None:
            return true
        }
    }
    
    var buttonTitle:String { return returnWagerStringFormat(betTypeOfButton: betTypeOfButton, game: game) }
        

    var body: some View {
        Button(action: action) {
            Text(isDisabled ? "" : buttonTitle)
                .foregroundColor(K.finalColor.titleBlue)
                .font(.custom(K.customFonts.lexendDecaMedium, size: buttonTitle.count < 6 ? 16 : 14))
        }
        .frame(width: 50, height: 30)
        .animation(.spring(), value: 4)
        .background(selectedBetType == betTypeOfButton ? K.finalColor.textWhite : K.finalColor.cardBlue)
        .disabled(isDisabled)
        .overlay(
                RoundedRectangle(cornerRadius: selectedBetType == betTypeOfButton ? 7.5 : 7.5)
                    .stroke(selectedBetType == betTypeOfButton ? Color.blue : Color.gray, lineWidth: 1.0)
            )
        .cornerRadius(selectedBetType == betTypeOfButton ? 7.5 : 7.5)
        .shadow(color: selectedBetType == betTypeOfButton ? K.veryLightBlue : .clear, radius: 3)
        .scaleEffect(selectedBetType == betTypeOfButton ? 1.05 : 1.0)
    }
}


struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}




struct screen2PopUp: View {
    
    let game: Game
    @Binding var betType: BetType
    @ObservedObject var viewModel: bookViewModel
    @Binding var showingSheet: Bool
    @State var onDailyChallenge: Bool = true
    @Binding var poolBucks: Double
    

    
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])

            VStack {
                popUpPill()
                HStack(spacing: 15) {
                    Button(action: {
                        onDailyChallenge = true
                    }, label: {
                        HStack {
                        Text("Daily")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(.white)
                        }.frame(width: 150, height: 30).background(onDailyChallenge ? K.finalColor.titleBlue : K.finalColor.cardBlue).cornerRadius(7.5)

                    })
                    Button(action: {
                        onDailyChallenge = false
                    }, label: {
                        HStack {
                            Text("Peer to Peer")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                        }.frame(width: 150, height: 30).background(!onDailyChallenge ? K.finalColor.titleBlue : K.finalColor.cardBlue).cornerRadius(7.5)
                    })
                }.padding(.vertical, 10)
                if onDailyChallenge {
                    dailyChallengeSubmitView(game: game, betType: $betType, viewModel: viewModel, showingSheet: $showingSheet)
                } else {
                    peer2peerSubmitPage(game: game, betType: betType, showingSheet: $showingSheet)
                }
            }
        }.onDisappear() {
            poolBucks = StaticUserData.shared.currentUser.poolBucks
        }
    }
}

struct CustomToggleStyle: ToggleStyle {
    var onColor: Color
    var offColor: Color
    var knobColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Rectangle()
                .foregroundColor(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .foregroundColor(knobColor)
                        .padding(.all, 3)
                        .offset(x: configuration.isOn ? 10 : -10, y: 0)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .cornerRadius(15)
                .onTapGesture { configuration.isOn.toggle() }
        }
        
    }
}
