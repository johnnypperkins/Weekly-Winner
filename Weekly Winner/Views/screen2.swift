//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase

struct BettingAppView: View {
//    @State private var selectedGameType = GameType.nfl
    @StateObject private var viewModel = bookViewModel()
    @State private var showingSheet = false
    @State private var isShowing = false

    var body: some View {
        ZStack{
            if isShowing {
                sideMenuView(bookVM: viewModel, isShowing: $isShowing)
            }
            VStack {
                    

                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowing.toggle()
                        }
                    },label:  {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                            .padding(.leading) // Add padding to the left side of the button
                    })
                    Spacer()
                }
                Text(viewModel.selectedGameType)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                HStack {
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Team Name") // team name
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            HStack(spacing: 20) {
                                Text("Spread")
                                    .foregroundColor(.black)
                                    .frame(width: 50)
                                    .font(.subheadline)
                                Text("Total")
                                    .foregroundColor(.black)
                                    .frame(width: 50)
                                    .font(.subheadline)
                            }
                            
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 7.5)
                                .fill(K.veryLightBlue)
                        )

                        
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .background(Color.white)
               
                
                ScrollView {
                    VStack(spacing: 5) {
                        if viewModel.selectedGameType == "NFL" {
                            ForEach(viewModel.NFLgames, id: \.idd) { game in // HARDCODE NCAAF
                                BetRowView1(game: game)
                            }.padding(.horizontal)
                        }
                        if viewModel.selectedGameType == "NCAAF" {
                            ForEach(viewModel.NCAAFGames, id: \.idd) { game in // HARDCODE NCAAF
                                BetRowView1(game: game)
                            }.padding(.horizontal)
                        }
                        if viewModel.selectedGameType == "Upcoming" {
                            ForEach(viewModel.upcomingGames, id: \.idd) { game in 
                                BetRowView1(game: game)
                            }.padding(.horizontal)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(isShowing ? 50 : 30)
                .blur(radius: isShowing ? 8 : 0)
                .offset(x:isShowing ? 300 : 0, y: isShowing ? 100 : 0)
                .scaleEffect(isShowing ? 0.8 : 1)
            }

            .navigationBarHidden(false)
        }
    
    private var filteredGames: [Game] {
        switch viewModel.selectedGameType {
        case "Upcoming":
            return viewModel.upcomingGames
        case "NCAAF":
            // return array of college football games from your viewModel
            return viewModel.NCAAFGames
        case "NFL":
            // return array of NFL games from your viewModel
            return viewModel.NFLgames
        default:
            return []
        }
    }
}

struct BetRowView1: View {
    let game: Game
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false // placeBet thing pops up
    @State private var betType: BetType = .None
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    
    var maxHeight = 100
    var maxWidth = 100
    
    var body: some View {
      
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Text(game.homeTeam) // team name
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    HStack(spacing: 20) {
                        BetButton(betType: .betHomeSpread, currentBetType: $betType, title: titleStringH) { // home spread
                            betType = .betHomeSpread
                            showingSheet.toggle()
                        }
                        
                        BetButton(betType: .over, currentBetType: $betType, title: "o" + String(format: "%.0f", game.totalOver)) { // over
                            betType = .over
                            showingSheet.toggle()
                        }
                    }
                    
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                HStack {
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 20) {
                        BetButton(betType: .betAwaySpread, currentBetType: $betType, title: titleStringA) {
                            betType = .betAwaySpread
                            showingSheet.toggle()
                        }
                        
                        BetButton(betType: .under, currentBetType: $betType, title: "u" + String(format: "%.0f", game.totalUnder)) {
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
                Text("\(formatDate.format(date: game.commenceTime.dateValue()))")
                    .font(.footnote)
                    .foregroundColor(K.veryLightGray)
                    .frame(maxWidth: .infinity, alignment: .center)
                //Spacer().frame(height: -5) // Adjust this value to move the Text view up
            }
            
            //Spacer()
        }.padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        .padding()
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSheet) {
            BetDetailsView(game: game, betType: $betType)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .onDisappear(){
                    withAnimation{
                        betType = .None
                    }
                }
                
        }
    }
}

// the pop up thing
struct BetDetailsView: View {
    let game: Game
    @Binding var betType: BetType
    
    @Environment(\.dismiss) var dismiss
    @State private var chosenSpread: Double = 2
    @State private var originalSpread: Double = 2
    @ObservedObject var viewModel = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    
    @State private var groupNumber = 0
    @State private var betNumber = -99
    @State private var groupDict: [String: Int] = [:]
    @State private var whichTeam = ""
    @State private var extra = "" // to add the extra detail of +, o, u
    @State private var uploadText = ""
    
    func checkTeamTaken() {
        if betNumber < 0 {
            uploadText = "Ticket Full"
        } else {
            if ticketVM.isTeamAvailable(whichTeam, groupNumber, betType) {
                uploadText = "Place Bet"
            } else {
                uploadText = "Team Taken"
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack{
                Button {
                    withAnimation {
                        dismiss()
                        betType = .None
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }.padding(.top)
                Spacer()

            }.frame(maxWidth:.infinity, alignment: .center)
                .padding(.leading)
            
            VStack {
                HStack (spacing: 0){
                    VStack (spacing: 0) {
                        //Spacer()

                        Text("Group")
                            .frame(maxWidth: 200, alignment: .center)
                            .font(.subheadline)
                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .background(K.veryLightBlue)
                        
                        //Spacer()
                        
                        if ticketVM.isBetsLoaded {
                            //Spacer()
                            Picker("Group", selection: $groupNumber) {
                                ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                                    Text(viewModel.userGroups[index].groupName).tag(index)
                                }
                            }
                            .frame(maxWidth: 200, alignment: .center)
                            .pickerStyle(WheelPickerStyle())
                            .onChange(of: groupNumber) { newValue in
                                ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: newValue) {
                                    if !ticketVM.availableBets(for: newValue).isEmpty {
                                        betNumber = ticketVM.availableBets(for: groupNumber)[0]
                                    } else {
                                        betNumber = -99
                                    }
                                    checkTeamTaken()
                                }
                            }
                            .onAppear {
                                if !ticketVM.availableBets(for: groupNumber).isEmpty {
                                    betNumber = ticketVM.availableBets(for: groupNumber)[0]
                                } else {
                                    betNumber = -99
                                }
                                checkTeamTaken()
                            }
                            .background(K.veryLightGray)
                        }
                    }//.padding(.horizontal)
                        //.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                    //.background(K.veryLightBlue)
                    VStack (spacing: 0){
                        Text("Bet")
                            .frame(maxWidth: 200, alignment: .center)
                            .font(.subheadline)
                            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .background(K.veryLightBlue)
                        if ticketVM.isBetsLoaded {
                            Picker("Bet Type", selection: $betNumber) { // starts at 1 bc "1 leg"
                                if betNumber >= 0 {
                                    ForEach(ticketVM.availableBets(for: groupNumber), id: \.self) { index in //
                                        switch index {
                                        case 1: Text("Straight #1").tag(1)
                                        case 2: Text("Straight #2").tag(2)
                                        case 3: Text("Straight #3").tag(3)
                                        case 4: Text("Straight #4").tag(4)
                                        case 5: Text("2leg #1").tag(5)
                                        case 6: Text("2leg #2").tag(6)
                                        case 7: Text("3leg").tag(7)
                                        case 8: Text("5leg").tag(8)
                                        default: EmptyView()
                                        }
                                    }
                                } else {
                                    Text("FULL")
                                }
                            }
                            .frame(maxWidth: 200, alignment: .center)
                            .pickerStyle(WheelPickerStyle())
                            .onChange(of: betNumber) { newValue in
                                print("Selection changed to: \(newValue)")
                                checkTeamTaken()
                            }
                            .onAppear {
                                print("\(betNumber) is original betNumber")
                            }
                            .background(K.veryLightGray)
                        }
                    }//.padding(.horizontal)
                    //.background(K.veryLightGray)
                }.cornerRadius(10)
                    // .padding(.horizontal)
                
                if betType == .betAwaySpread {
                    BetView(teamName: game.awayTeam, originalSpread: game.awaySpread, betType: .betAwaySpread, chosenSpread: $chosenSpread)
                }
                if betType == .betHomeSpread {
                    BetView(teamName: game.homeTeam, originalSpread: game.homeSpread, betType: .betHomeSpread, chosenSpread: $chosenSpread)
                }
                if betType == .over {
                    BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalOver, betType: .over, chosenSpread: $chosenSpread)
                }
                if betType == .under {
                    BetView(teamName: "\(game.awayTeam) / \(game.homeTeam)", originalSpread: game.totalUnder, betType: .under, chosenSpread: $chosenSpread)
                }
            }
            .onAppear {
                ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber) {
                    if !ticketVM.availableBets(for: groupNumber).isEmpty {
                        betNumber = ticketVM.availableBets(for: groupNumber)[0]
                    } else {
                        betNumber = -99
                    }
                    checkTeamTaken()
                }
                print("Group Number: \(groupNumber), Bet Number: \(betNumber)")
            } // whole thing
            //.background(K.veryLightGray)
            //.cornerRadius(10)
            .padding()
            .padding(.horizontal)
                
            
        Button(action: {
            print("groupNumber: \(groupNumber), betNumber: \(betNumber)")
            viewModel.uploadBet(groupNumber: groupNumber, betNumber: betNumber, team: whichTeam, betLine: chosenSpread, betOdds: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread)), betType: betType, gameID: game.idd ?? "null") {_ in
                ticketVM.fetchBets(uid: Auth.auth().currentUser!.uid, groupNumber: groupNumber, completion: {
                    let groupServe = groupService()
                    groupServe.setPotentialToWin(potential: Int(ticketVM.totalPotentialWon), groupNumber: groupNumber, completion: {_ in })
                })
            }
                withAnimation {
                    dismiss()
                    betType = .None
                }
            
               }, label: {
                   Text(uploadText)
                       .font(.title)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                       .padding()
                       .frame(maxWidth: .infinity)
                       .background(
                           LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                       )
                       .cornerRadius(10)
                       .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
               })
        .disabled(betNumber < 0 || !ticketVM.isTeamAvailable(whichTeam, groupNumber, betType))
        .padding(.horizontal)
        .padding(.horizontal)
        }
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
        //.padding(.horizontal)
    }
}


struct BetView: View {
    var teamName: String
    var originalSpread: Double
    //var extra: String
    var internalExtra: String {
        if chosenSpread < 0 {
                    return ""
                } else {
                    switch betType {
                    case .betHomeSpread:
                        return "+"
                    case .betAwaySpread:
                        return "+"
                    case .over:
                        return "o"
                    case .under:
                        return "u"
                    default:
                        return ""
                    }
                }
    }
    var betType: BetType // 1 AS, 2 HS, 3 O, 4 U
    @Binding var chosenSpread: Double

    var body: some View {
        VStack (spacing: 0){
            HStack (spacing: 10) {
                Text("Team")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text("Spread")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(width: 50, alignment: .leading)
                Text("Odds")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                .padding(.horizontal)
                .background(K.veryLightBlue)
            HStack (spacing: 10){
                Text("\(teamName)")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text("\(internalExtra)\(String(format: "%.0f", chosenSpread))")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, alignment: .leading)
                Text("\(percentageToML(percentage: returnOdds(betType: betType, ogSpr: Int(originalSpread), chsSpr: Int(chosenSpread))))")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 65, alignment: .trailing)
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                .background(K.veryLightGray)
            
            
            HStack {
                //Text("Spread/total:")
                  //  .font(.headline)
                Slider(value: $chosenSpread, in: Double(originalSpread - 5)...Double(originalSpread + 5), step: 1)
                    .accentColor(Color(.green))
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .padding(.horizontal)
                .background(K.veryLightGray)
        }.cornerRadius(10)
    }
}

struct BetButton: View {
    let betType: BetType
    @Binding var currentBetType: BetType
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(minWidth: 35, maxWidth: 35, alignment: .center)
                .foregroundColor(.blue)
                .padding(10)
                .background(Color(currentBetType == betType ? .gray : .white))
                .cornerRadius(currentBetType == betType ? 20 : 10)
                .shadow(color: currentBetType == betType ? .gray : .clear, radius: 5)
                .scaleEffect(currentBetType == betType ? 0.9 : 1.0)
        }
        .frame(width: 50, height: 45)
        .animation(.spring(), value: 4)
    }
}


struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}
