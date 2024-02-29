//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct challengePage3: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var showingSheet = false
    @State private var isShowing = false

    func shouldAppear(search: String, input: String) -> Bool {
        return input.lowercased().contains(search.lowercased())
    }
    


    var body: some View {
        NavigationStack {
            ZStack{
                K.finalColor.backgroundBlue
                VStack {
                    
                    HStack{
                        Text("Team Name") // team name
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.leading)
                        Spacer()
                        HStack(spacing: 15) {
                            Text("Spr")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(K.finalColor.textWhite)
                                .frame(width: 50, alignment: .center)
                            Text("Tot")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(K.finalColor.textWhite)
                                .frame(width: 50, alignment: .center)
                                .padding(.trailing, 9)
                        }
                        
                        //Divider()
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
                        .padding(.horizontal)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                            //.padding(.top, 100)
                                .padding(.horizontal)
                                .foregroundColor(.white), alignment: .bottom)
                    
                    ScrollView {
                        VStack(spacing: 5) {
                            // Displaying games
                            if !viewModel.selectedGames.isEmpty {
                                ForEach(viewModel.selectedGames, id: \.idd) { game in
                                    //                                    if game.commenceTime.dateValue() > Date() {
                                    gameRowViewCHALLENGE(game: game, isDisabled: false, viewModel: viewModel)
                                    //                                    }
                                }.padding(.horizontal)
                            }
                        }.padding(.bottom,20)
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        .frame(height: 240)
                    
                    Rectangle()
                        .frame(height: 1)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    challengeBetsDisplay(uid: Auth.auth().currentUser!.uid, viewModel: viewModel)
                     
                    
                    Spacer()
                    
                    if viewModel.totalPotentialWon > 0 && !viewModel.totalBetArrays.contains(where: { $0.isEmpty }) {
                        NavigationLink(destination: {
                            challengePage4(viewModel: viewModel).background(K.finalColor.backgroundBlue)
                                .onAppear() {
                                    viewModel.canDeleteBets = false
                                }
                        }, label: {
                            HStack{
                                Spacer()
                                Text("Finalize Challenge")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                                .background(K.finalColor.winningGreen)
                                .cornerRadius(10)
                                .padding(.horizontal,16)
                                .padding(.bottom,10)
                        })
                        
                        
                    } else {
                        HStack{
                            Spacer()
                            Text("Fill Ticket")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(K.finalColor.deleteRed)
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(K.finalColor.backgroundBlue)
                .cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
            }.background(K.finalColor.backgroundBlue)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 40, trailing: 0))
                .navigationBarHidden(false)
        }
    }
}

struct PlaceBetButtonCHALLENGE: View {
    let isDisabled: Bool
    let betType: BetType
    @Binding var currentBetType: BetType
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                //.frame(minWidth: 35, maxWidth: 35, alignment: .center)
                .foregroundColor(K.finalColor.titleBlue)
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                
        }
        .frame(width: 50, height: 30)
        .animation(.spring(), value: 4)
        .background(currentBetType == betType ? K.finalColor.textWhite : K.finalColor.cardBlue)
        .overlay(
                RoundedRectangle(cornerRadius: currentBetType == betType ? 7.5 : 7.5)
                    .stroke(currentBetType == betType ? Color.blue : Color.gray, lineWidth: 1.0)
            )
        .cornerRadius(currentBetType == betType ? 7.5 : 7.5)
        .shadow(color: currentBetType == betType ? K.veryLightBlue : .clear, radius: 3)
        .scaleEffect(currentBetType == betType ? 1.05 : 1.0)
        .disabled(isDisabled)
        
        
    }
}

struct gameRowViewCHALLENGE: View {
    let game: Game
    let isDisabled: Bool
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betType: BetType = .None
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    @ObservedObject var viewModel: challengeViewModel

    
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
                    HStack(spacing: 15) {
                        PlaceBetButton(game: game, betTypeOfButton: .betHomeSpread, selectedBetType: $betType) { // home spread
                            betType = .betHomeSpread
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
                    HStack(spacing: 15) {
                        PlaceBetButton(game: game, betTypeOfButton: .betHomeSpread, selectedBetType: $betType) {
                            betType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        PlaceBetButton(game: game, betTypeOfButton: .under, selectedBetType: $betType) {
                            betType = .under
                            showingSheet.toggle()
                        }
                    }
                }.padding(.top,4)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                    .onAppear {
                        if (game.homeSpread < 0) {
                            titleStringH = String(format: "%.0f", game.homeSpread)
                        } else {
                            titleStringH = "+" + String(format: "%.0f", game.homeSpread)
                        }
                        if (game.awaySpread < 0) {
                            titleStringA = String(format: "%.0f", game.awaySpread)
                        } else {
                            titleStringA = "+" + String(format: "%.0f", game.awaySpread)
                        }
                    }
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
        .sheet(isPresented: $showingSheet) {
            BetDetailsViewCHALLENGE(game: game, ticketFormat: viewModel.ticketFormat /*WILL FIX*/, betType: $betType, viewModel: viewModel)
                .padding(.horizontal)
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .background(K.finalColor.backgroundBlue)
            .onDisappear(){
                withAnimation{
                    betType = .None
                }
            }
        }
    }
}

// the pop up thing
struct BetDetailsViewCHALLENGE: View {
    let game: Game
    let ticketFormat: [Int]
    @Binding var betType: BetType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = -99
    @State private var originalSpread: Double = -99
    @ObservedObject var viewModel: challengeViewModel
//    @StateObject var ticketVM = ticketViewModel()
    
    @State private var groupNumber = 0
    @State private var betNumber = -99
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    @State private var extra = "" // to add the extra detail of +, o, u
    @State private var uploadText = ""
    @State private var placeBetOpacity = 1.0
    @State private var placeBetColor: Color = Color.clear
    @State private var placeholder = 5
    
    @State private var timeFrame = "daily"
    
    
    func checkTeamTaken() {
        

            if betNumber < 0 {
                uploadText = "Ticket Full"
                placeBetOpacity = 0.6
                placeBetColor = K.finalColor.titleBlue.opacity(0.6)
            } else {
                if viewModel.isTeamAvailable(whichTeam, groupNumber, betType) {
                    uploadText = "Place Bet"
                    placeBetOpacity = 1
                    placeBetColor = K.finalColor.winningGreen
                    
                } else {
                    uploadText = "Team Taken"
                    placeBetOpacity = 0.6
                    placeBetColor = K.finalColor.titleBlue.opacity(0.6)
                    
                }
            }
    }
    
    var body: some View {
            
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            VStack {
                HStack (){
                    Spacer()
                    Button {
                        withAnimation {
                            dismiss()
                            betType = .None
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.white)
                    }.padding([.top, .trailing])
                }
                VStack {
                    HStack (spacing: 20){
                        VStack {
                                VStack {
                                    Text("Challenge Ticket")
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .foregroundColor(K.finalColor.textWhite)
                                        .frame(width: 240, alignment: .leading)
                                        //.padding(EdgeInsets(top: 70, leading: 15, bottom: 0, trailing: 0))
                                        .background(K.finalColor.backgroundBlue)
                                }
                                VStack {
                                    
                                        ScrollView {
                                                if betNumber >= 0 {
                                                    ForEach(0..<1, id: \.self) { _ in
                                                        let availableBets = viewModel.availableBetsArray
                                                        let ticketFormat = viewModel.ticketFormat
                                                        ForEach(0..<availableBets.count, id: \.self) { index in
                                                            if availableBets[index] > 0 {
                                                                Button(action: {
                                                                    betNumber = index + 1
                                                                    print("Selection changed to: \(index+1)")
                                                                    checkTeamTaken()
                                                                    if betNumber <= viewModel.ticketFormat.count && betNumber > 0 {
                                                                        if ticketFormat[index] == 5 {
                                                                            if betType == .betAwaySpread {
                                                                                chosenSpread = game.awaySpread + 1
                                                                            }
                                                                            if betType == .betHomeSpread {
                                                                                chosenSpread = game.homeSpread + 1
                                                                            }
                                                                            if betType == .over {
                                                                                chosenSpread = game.totalOver - 1
                                                                            }
                                                                            if betType == .under {
                                                                                chosenSpread = game.totalUnder + 1
                                                                            }
                                                                        }
                                                                    } else {
                                                                        if betType == .betAwaySpread {
                                                                            chosenSpread = game.awaySpread
                                                                        }
                                                                        if betType == .betHomeSpread {
                                                                            chosenSpread = game.homeSpread
                                                                        }
                                                                        if betType == .over {
                                                                            chosenSpread = game.totalOver
                                                                        }
                                                                        if betType == .under {
                                                                            chosenSpread = game.totalUnder
                                                                        }
                                                                    }
                                                                }, label: {
                                                                    HStack {
                                                                        Text(parlayTitle(ticketFormat: ticketFormat, index: index)).tag(index+1)
                                                                            .foregroundColor(K.finalColor.textWhite)
                                                                            .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
                                                                    }.frame(width: 240, height: 30, alignment: .center)
                                                                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                                                        .background(betNumber == index+1 ? K.finalColor.titleBlue : K.veryLightGray.opacity(0.4))
                                                                        .cornerRadius(5)
                                                                })
                                                            }
                                                        }
                                                    }
                   
                                                } else {
                                                    VStack {
                                                        Spacer()
                                                        VStack (alignment: .center){
                                                            
                                                            Text("Challenge")
                                                                .foregroundColor(K.finalColor.textWhite)
                                                                .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                                            Text("Complete")
                                                                .foregroundColor(K.finalColor.textWhite)
                                                                .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                                            
                                                        }
                                                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                                        .background(K.finalColor.titleBlue.opacity(0.6))
                                                        .cornerRadius(5)
                                                        
                                                        //.scaleEffect(x: 2)
                                                        Spacer()
                                                        
                                                    }.padding(.top,15)
                                                }
                                        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                    
                                }.frame(width: 240, height: 100)
                                    .padding(.horizontal)
                                    .onAppear {
                                        if let firstNumberGreaterThanZero = viewModel.availableBetsArray.first(where: { $0 > 0 }) {
                                            betNumber = firstNumberGreaterThanZero
                                        } else {
                                            betNumber = -99
                                        }
                                        checkTeamTaken()
                                    }
                                    .background(K.finalColor.cardBlue)
                                    .cornerRadius(7.5)
                            
                        }
                        
                    }.cornerRadius(10)
//                    
//                    if betType == .betAwaySpread {
//                        BetSliderView(whichSport: game.whichSport, teamName: game.awayTeam, originalSpread: game.awaySpread, parlaySize: betNumber <= ticketFormat.count && betNumber > 0 ? ticketFormat[betNumber-1] : 1, betType: .betAwaySpread, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//                    }
//                    if betType == .betHomeSpread {
//                        BetSliderView(whichSport: game.whichSport, teamName: game.homeTeam, originalSpread: game.homeSpread, parlaySize: betNumber <= ticketFormat.count && betNumber > 0 ? ticketFormat[betNumber-1] : 1, betType: .betHomeSpread, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
//                    if betType == .over {
//                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, parlaySize: betNumber <= ticketFormat.count && betNumber > 0 ? ticketFormat[betNumber-1] : 1, betType: .over, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
//                    if betType == .under {
//                        BetSliderView(whichSport: game.whichSport, teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, parlaySize: betNumber <= ticketFormat.count && betNumber > 0 ? ticketFormat[betNumber-1] : 1, betType: .under, chosenSpread: $chosenSpread)
//                            //.padding(.horizontal)
//
//                    }
                    
                }
                .background(K.finalColor.backgroundBlue)
                    
                Button(action: {
                    print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
                    
                    viewModel.uploadChallengeBet(bet: 
                                                    Bet(id: "" /*WILL ADD*/,
                                                        groupNumber: 0, groupID: "",
                                                        betNumber: betNumber,
                                                        weekNumber: 0,
                                                        betType: betType,
                                                        teamBetOn: whichTeam, 
                                                        betLine: Float(chosenSpread),
                                                        betOdds: Float(returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread), whichSport: game.whichSport)),
                                                        result: .notStarted,
                                                        gameID: game.idd,
                                                        whichSport: game.whichSport,
                                                        timestamp: Timestamp(date: Date()),
                                                        points_bought: Int(chosenSpread-originalSpread))
                    )
                    
                    withAnimation {
                        dismiss()
                        betType = .None
                    }
                    
                }, label: {
                    Text(uploadText)
                        .foregroundColor(.white)
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 20.0))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(placeBetColor)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        //f.padding(.horizontal, 25)
                })
                .disabled(betNumber < 0 || !viewModel.isTeamAvailable(whichTeam, groupNumber, betType))
                .padding(.horizontal)
                .background(K.finalColor.backgroundBlue)
            }.padding(.horizontal)
            .onAppear(perform: {
                if betType == .betAwaySpread {
                    chosenSpread = game.awaySpread
                    originalSpread = game.awaySpread
                    whichTeam = game.awayTeam
                }
                if betType == .betHomeSpread {
                    chosenSpread = game.homeSpread
                    originalSpread = game.homeSpread
                    whichTeam = game.homeTeam
                }
                if betType == .over {
                    chosenSpread = game.totalOver
                    originalSpread = game.totalOver
                    whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
                }
                if betType == .under {
                    chosenSpread = game.totalUnder
                    originalSpread = game.totalUnder
                    whichTeam = "\(game.homeTeam) / \(game.awayTeam)"
                }
            })
        }
    }
}


