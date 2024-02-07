//
//  challengeView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 1/1/24.
//

// test comment

import Foundation
import SwiftUI
import Kingfisher
import PopupView

struct challengeView: View {
    @State var tabSelected = 0

    @ObservedObject var challengeVM = challengeViewModel()
    
    @State private var showRulesPage = false
    
    @State var poolBucks = StaticUserData.shared.currentUser.poolBucks
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Challenges"
        case 1: return "Pending"
        case 2: return "Completed"
        default: return "PoolCoins"
        }
    }

    private func offsetForSelectedTab() -> CGFloat {
        let baseOffset: CGFloat = -240
        let tabWidth: CGFloat = 120
        let offset = baseOffset + CGFloat(tabSelected + 1) * tabWidth
        return offset
    }
    
    

    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue
            VStack(alignment: .trailing){
                HStack{
                    currencyView(poolCoins: StaticUserData.shared.currentUser.poolCoins, poolBucks: $poolBucks)
                    
                    Spacer()

                    NavigationLink(destination: settingsView(), label: {
                        
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .background(Color.red.padding(40)) // Add this line
                                .frame(width: 40, height: 40)
                                .background(K.finalColor.cardBlue)
                                .cornerRadius(7.5)
                    })
                    .id(UUID())
                    
                }.padding(.horizontal)

                Spacer()
            }.padding(.top,50)
            
            VStack {
                VStack (spacing: 4) {
                    HStack (spacing: 0) {
                        ForEach(0..<3, id: \.self) { index in
                            Button(action: {
                                tabSelected = index
                            }) {
                                Text(tabTitle(for: index))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 35, alignment: .center)
                                    .cornerRadius(5)
                            }
                        }
                    }.padding(.top, 35)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 90, height: 3)
                        .cornerRadius(1)
                        .offset(x: offsetForSelectedTab(), y: 0)
                        .animation(.easeInOut(duration: 0.35))
                }.padding(.top, 40)
                 .cornerRadius(7.5)
                if tabSelected == 0 {
                    challengeCardView(viewModel: challengeVM, poolBucks: $poolBucks)
                        .padding(.top, 20)
                } else if tabSelected == 1 {
                    pendingCardView(viewModel: challengeVM)
                } else if tabSelected == 2 {
                    finishedCardView(viewModel: challengeVM)
                }
                
                
                Spacer()
            }/*.background(K.finalColor.backgroundBlue)*/
            .padding(.top,30)
        }
        
    }
        
}




struct challengeCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var showRulesPage = false
    @Binding var poolBucks: Double
    var body: some View {
        ScrollView {
            VStack (spacing: 10) {
                VStack {
                    HStack {
                        NavigationLink(destination: {challengePage1(viewModel: viewModel)}, label: {
                            Text("Create a challenge +")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                        })
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal,15)
                
                VStack {
                    Button {
                        showRulesPage.toggle()
                    } label: {
                        HStack {
                            Text("What are challenges?")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            
                        }
                    }

                    
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal,15)
                
                VStack {
                    Button {
                        showRulesPage.toggle()
                    } label: {
                        HStack {
                            Text("What are PoolBucks?")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            
                        }
                    }

                    
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal,15)
                
                VStack {
                    HStack {
                        NavigationLink {
                            purchaseCurrencyView()
                                .background(K.finalColor.backgroundBlue)
                        } label: {
                            HStack (spacing: 7.5){
                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Deposit/Withdraw")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Image("poolBuck")
                                    .resizable()
                                    .frame(width: 20, height: 20)


                            }
                      
                        }
                        
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                .padding(.horizontal,15)
            }
        }.refreshable {
            viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {
                poolBucks = StaticUserData.shared.currentUser.poolBucks
                }
            }
        .onAppear() {
            viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {
                poolBucks = StaticUserData.shared.currentUser.poolBucks
                }
            }        
        .popup(isPresented: $showRulesPage) {
            Text("The popup")
                challengeDescription()
                .frame(height: 500)

        } customize: {
            $0
                .type (.toast)
                .position(.bottom)
                //.dragToDismiss(true)
                .isOpaque(true)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.4))

        }
    }
}






struct challengePage1: View {
    @State var currencyChosen = "poolBucks"
    @State private var opponentUsername: String = ""
    @State private var selectedUserID: String = ""
    @State private var wagerAmount: Double = 0
//    let maxWagerAmount: Double = 100
    
    @State private var oneLegNum: Int = 0
    @State private var twoLegNum: Int = 0
    @State private var threeLegNum: Int = 0
    @State private var fourLegNum: Int = 0
    @State private var fiveLegNum: Int = 0
    
    @ObservedObject var viewModel: challengeViewModel
    
    
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
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue
                VStack {
                    HStack {
                        if maxSliderValue == 1.69 {
                            Text("Add More!")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 50))
                                .foregroundColor(.white)
                        }else{
                            Image(currencyChosen == "poolCoins" ? "poolCoin" : "poolBuck")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("\(String(format: "%.2f", wagerAmount)) : \(String(format: "%.2f", wagerAmount*0.952))")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 45))
                                .foregroundColor(.white)
                            
                        }
                    }.padding(.top, 10)
                    HStack (spacing: 20){
                        Button(action: {
                            if currencyChosen != "poolBucks" {
                                withAnimation {
                                    currencyChosen = "poolBucks"
                                    wagerAmount = 0
                                }
                                
                            }
                        }) {
                            HStack {
                                Text("PoolBucks")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "poolBucks" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                        Button(action: {
                            if currencyChosen != "poolCoins" {
                                withAnimation {
                                    currencyChosen = "poolCoins"
                                    wagerAmount = 0
                                }
                                
                            }
                        }) {
                            HStack {
                                Text("PoolCoins")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "poolCoins" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                    }
                    
                    VStack {
                        HStack{
                            Text("Adjust Bet Amount")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                            Spacer()
//                            Text(String(format: "%.1f", wagerAmount))
//                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
//                                .foregroundColor(.white)
                        }
                        Slider(value: $wagerAmount, in: 0.0...maxSliderValue, step: 1) { editing in
                            
                        }
                        
                        .accentColor(.white)
                        //.background(Color(red: 0.77, green: 0.85, blue: 0.98).blur(radius: 15).opacity(0.60))
                        
                        
                    }.padding(.horizontal,20)
                        .padding(.vertical,10)
                    
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
                    VStack {
                        CustomStepper2(value: $oneLegNum, range: 0...3, title: "Wagers")
                            .padding(.horizontal,14)
                            .padding(.top,10)
                    }
                    Spacer()

      
                    // user, amount, ticketformat
                    if wagerAmount > 0 && !viewModel.queriedUsers.isEmpty && oneLegNum > 0 {
                        NavigationLink(destination: {
                            challengePage2(
                                viewModel: viewModel,
                                currencyChosen: currencyChosen,
                                opponentUsername: opponentUsername,
                                selectedUserID: selectedUserID,
                                wagerAmount: wagerAmount,
                                ticketFormat: customizeTicketFormat(oneLegNum, 0, 0, 0, 0)
                            ).background(K.finalColor.backgroundBlue)
                                .onAppear {
                                    viewModel.setTicketFormat(ticketFormat: customizeTicketFormat(oneLegNum, 0, 0, 0, 0))
                                    viewModel.currencyChosen = currencyChosen
                                    viewModel.wagerAmount = wagerAmount
                                    viewModel.opponentUsername = opponentUsername
                                    viewModel.opponentID = selectedUserID
                                }
                            
                        }, label: {
                            HStack{
                                Spacer()
                                Text("Choose Games")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                                .background(K.finalColor.winningGreen)
                                .cornerRadius(10)
                                .padding(.horizontal,16)
                                .padding(.bottom,20)
                        })
                    } else {
                        HStack{
                            Spacer()
                            Text("Fill Challenge Fields")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(K.finalColor.deleteRed.opacity(0.6))
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,20)
                    }
                    
                    //Spacer()
                }
            }.onAppear() {
                viewModel.selectedGames = []
                viewModel.selectedGameIDs = []
            }
        }.background(K.finalColor.backgroundBlue)
    }
    var maxSliderValue: Double {
        let defaultValue: Double = 1.69 // Set a default or minimum value for the slider

        if currencyChosen == "poolCoins" {
            return max(StaticUserData.shared.currentUser.poolCoins, defaultValue)
        } else {
            return max(StaticUserData.shared.currentUser.poolBucks, defaultValue)
        }
    }
}
    
struct challengePage2: View {
    @ObservedObject var viewModel: challengeViewModel
    
    let currencyChosen: String
    let opponentUsername: String
    let selectedUserID: String?
    let wagerAmount: Double
    let ticketFormat: [Int]
    
    
//    @State var challengeFormat = "gameBased"
    @State var amountTime = 1
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                VStack (spacing: 4) {
                    Text("Choose Games")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                        .foregroundColor(.white)
                        .frame(width: 150, height: 40, alignment: .center)
                        .cornerRadius(5)
                    gameBasedView(viewModel: viewModel)
                Spacer()
                if !viewModel.selectedGames.isEmpty {
                    NavigationLink(destination: {
                        challengePage3(
                            viewModel: viewModel
                        ).background(K.finalColor.backgroundBlue)
                            .onAppear() {
                                viewModel.canDeleteBets = true
                            }
                    }, label: {
                        HStack{
                            Spacer()
                            Text("Continue To Bets")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(K.finalColor.winningGreen)
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,20)
                    })
                } else {
                    HStack{
                        Spacer()
                        Text("Select a Game")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                        .background(K.finalColor.deleteRed)
                        .cornerRadius(10)
                        .padding(.horizontal,16)
                        .padding(.bottom,20)
                }
                
                }.padding(.top, 10)
            }.background(K.finalColor.backgroundBlue)
        }
    }
}


struct searchBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        HStack {
            TextField("Search", text: withAnimation{$keyword})
                .onChange(of: keyword) { keywordd in
                    keyword = keywordd.lowercased()
                }
                .placeholder(when: keyword == "", placeholder: {
                    Text("Search Users").foregroundColor(.gray)
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
        .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
    }
}



struct gameBasedView: View {
    
    @State var searchTerm = ""
//     var challengeFormat: String
    
    @ObservedObject var viewModel: challengeViewModel
    
    func shouldAppear(search: String, input: String) -> Bool {
        return input.lowercased().contains(search.lowercased())
    }
    
    var body: some View {
        VStack {
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
            
            ScrollView {
                VStack(spacing: 5) {
                    ForEach(viewModel.allGames, id: \.idd) { game in
                        if (shouldAppear(search: searchTerm, input: game.homeTeam) || shouldAppear(search: searchTerm, input: game.awayTeam) || searchTerm == "") {
                            if game.commenceTime.dateValue() > Date() {
                                gameRowImages(game: game, viewModel: viewModel, isSelected: viewModel.isGameSelected(gameId: game.idd), searchTerm: $searchTerm)

                            }
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct gameRowImages: View {
    
    let game: Game
    @ObservedObject var viewModel: challengeViewModel
    
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    @State var isSelected: Bool // FIX
    @Binding var searchTerm: String

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
                        PlaceBetImage(title: titleStringH)
                        PlaceBetImage(title: "o" + String(format: "%.0f", game.totalOver))
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                HStack {
                    Text("\(game.awayTeam)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 15) {
                        PlaceBetImage(title: titleStringA)
                        PlaceBetImage(title: "u" + String(format: "%.0f", game.totalUnder))
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
            .background(isSelected ? K.finalColor.winningGreen.opacity(0.7) : K.finalColor.cardBlue)
            .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation {
                isSelected.toggle()
            }
            
            viewModel.toggleGameSelection(game)
        
        }
//        .onChange(of: searchTerm) { _ in
//            if viewModel.selectedGameIDs.contains(game.idd) {
//                self.isSelected = true
//                print("HERE BLAHBLAH")
//            }
//
//        }
    }
    
    struct PlaceBetImage: View {

        let title: String

        var body: some View {
            Text(title)
                .foregroundColor(K.finalColor.titleBlue)
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                .frame(width: 50, height: 30)
                .animation(.spring(), value: 4)
                .background(K.finalColor.cardBlue)
                .overlay(
                        RoundedRectangle(cornerRadius: 7.5)
                            .stroke(Color.gray, lineWidth: 1.0)
                    )
                .cornerRadius(7.5)
                .shadow(color: .clear, radius: 3)
        }
    }
}


struct userBio: View {
    var user: User
    
    @State var checked = false
    @Binding var selectedUserID: String
    @Binding var selectedUserUsername: String
    
    var body: some View {
        Button {
            withAnimation {
                if selectedUserID == user.id {
                    selectedUserID = "" // Deselect if already selected
                    selectedUserUsername = ""
                } else {
                    selectedUserID = user.id ?? "" // Select the user
                    selectedUserUsername = user.username
                }
            }
        } label: {
            ZStack {
                VStack (spacing: 10) {
                    HStack {
                        HStack(spacing: 11) {
                            HStack(spacing: 0) {
                                
                                
                                HStack(spacing: 5) {
                                    if user.profileImageUrl != "" {
                                        KFImage(URL(string: user.profileImageUrl))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 24, height: 24)
                                    } else {
                                        Image(systemName: "photo.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 24, height: 24)
                                            .background(K.finalColor.tabSelectedBlue)
                                            .clipShape(Circle())
                                        
                                    }
                                    HStack(spacing: 0){
                                        Text("\(user.username) ")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                            .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                        
                                    }
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .frame(height: 24)
                            
                            Spacer()
                            
                            
                            
                            // Arrow
                            
                                Image(systemName: selectedUserID == user.id ? "checkmark.square" : "square")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                                
                                
                            }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            //.padding(.bottom,10)
                            
                        }
                    }
                    .padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                    .background(selectedUserID == user.id ? K.finalColor.otherPurple.opacity(0.35) : K.finalColor.cardBlue)
                    .cornerRadius(10)
                }
            }
        }
    }

struct currencyView: View {
    let poolCoins: Double
    @Binding var poolBucks: Double
    var body: some View {
        Rectangle()
        
            .frame(minWidth: 175, maxWidth: 175, minHeight: 40, maxHeight: 40)
            .foregroundStyle(K.finalColor.cardBlue)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .overlay(
                HStack {
                    HStack {
                        Image("poolCoin")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("\(String(format: "%.0f", poolCoins))")
                            .foregroundStyle(.white)
                            .font(.custom(K.customFonts.lexendDecaSB, size: 16))
                    }
                    Text("|")
                        .foregroundStyle(.white)
                        .font(.custom(K.customFonts.lexendDecaSB, size: 16))
                    
                    HStack {
                        Image("poolBuck")
                            .resizable()
                            .foregroundStyle(.green)
                            .frame(width: 20, height: 20)
                        Text("\(String(format: "%.2f", poolBucks))")
                            .foregroundStyle(.white)
                            .font(.custom(K.customFonts.lexendDecaSB, size: 16))
                    }
                }
            )
    }
}
