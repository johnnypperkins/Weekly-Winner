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
            VStack(alignment: .leading){
                HStack{
//                    Spacer()
                    currencyView(poolCoins: StaticUserData.shared.currentUser.poolCoins, poolBucks: $poolBucks)
                    Spacer()
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
                    challengeCardView(viewModel: challengeVM, poolBucks: $poolBucks) // what are challenges, etc.
                        .padding(.top, 20)
                } else if tabSelected == 1 {
                    pendingCardView(viewModel: challengeVM) // pending ones
                } else if tabSelected == 2 {
                    finishedCardView(viewModel: challengeVM)
                }
                Spacer()
            }
            .padding(.top,30)
        }
        
    }
        
}

struct FilterSheetView: View {
    @Binding var selectedSport: String
    @Binding var maxWagerAmount: Double
    @Binding var showOnlyFriends: Bool
    @Binding var filtered: [DirectChallengeTicket]
    @ObservedObject var viewModel: challengeViewModel
    @State var isExpanded = false
    
    @Environment(\.dismiss) private var dismiss
    
    var friendUIDs: [String]
    
    var body: some View {
        VStack {VStack{
            Text("Filter Challenges")
                .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                .foregroundColor(K.finalColor.titleBlue)
                .padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    Button(action: {
                        selectedSport = "All"
                    }) {
                        Text("All")
                            .font(.custom("LexendDeca-Medium", size: 18))
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .frame(width: 80, height: 30)
                            .background(selectedSport == "All" ? K.finalColor.titleBlue : Color.gray)
                            .cornerRadius(5)
                    }
                    ForEach(viewModel.sportsWithChallenges.keys.sorted(), id: \.self) { sport in
                        Button(action: {
                            selectedSport = sport
                        }) {
                            Text(sport)
                                .font(.custom("LexendDeca-Medium", size: 18))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                .frame(width: 80, height: 30)
                                .background(selectedSport == sport ? K.finalColor.titleBlue : Color.gray)
                                .cornerRadius(5)
                        }
                    }
                }.padding(.bottom, 6)
            }
            //                Section(header: Text("Sport")) {
            //                    Picker("Select Sport", selection: $selectedSport) {
            //                        Text("All").tag("All")
            //                        ForEach(viewModel.sportsWithChallenges.keys.sorted(), id: \.self) { key in
            //                            Text(key).tag(key)
            //                        }
            //                    }
            //                }
            
            
            
                
                HStack {
                    Text("Wager Amount: ")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    if maxWagerAmount != 0 {
                        Text("\(maxWagerAmount, specifier: "%.0f")")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundStyle(.white)
                    }
                    else {
                        Text("N/A")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down").foregroundStyle(.white) // Dropdown icon
                        .onTapGesture {
                            // Toggle expanded state when the icon is tapped
                            withAnimation{
                                isExpanded.toggle()
                            }
                        }
                }.padding()
            VStack {
                if isExpanded {
                    // Display the current value of the slider
               
                    
                    // Slider
                    Slider(value: $maxWagerAmount, in: 0...1000)
                        .accentColor(K.finalColor.titleBlue)
                        .foregroundStyle(.white)
                    
                    
                    HStack {
                        Text("0") // Min value
                            .foregroundStyle(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                        Spacer()
                        Text("\(StaticUserData.shared.currentUser.poolBucks, specifier: "%.0f")") // Max value
                            .foregroundStyle(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                    }
                }
                
            } // Adjust range as needed
            
            
            
            
            
            Button(action: {
                // Call your filterChallenges function
                filterChallenges()
                // Dismiss the current view or sheet
                withAnimation{
                    dismiss()
                }
            }, label: {
                Text("Apply Filter")
                    .fontWeight(.semibold) // Adjust the font weight as needed
                    .foregroundColor(.white) // Text color
                    .padding(.vertical, 10) // Vertical padding inside the button
                    .padding(.horizontal, 40) // Horizontal padding to increase button width
            })
            .frame(minWidth: 0, maxWidth: .infinity) // Make the button width flexible
            .background(K.finalColor.titleBlue) // Button background color
            .cornerRadius(25) // Adjust the corner radius to get the pill shape
            .padding()
            .padding(.bottom,50)
        }.padding(.horizontal)
        }.background(K.finalColor.cardBlue)
    }
    func filterChallenges() {
        if selectedSport == "All" {
            filtered = viewModel.publicPendingChallenges.filter { challenge in
                let wagerAmountCheck = maxWagerAmount > 0 ? challenge.receiverWagerAmount <= maxWagerAmount : true
                return wagerAmountCheck &&
                       (!showOnlyFriends || friendUIDs.contains(challenge.senderID))
            }
        } else {
            filtered = viewModel.sportsWithChallenges[selectedSport]?.filter { challenge in
                let wagerAmountCheck = maxWagerAmount > 0 ? challenge.receiverWagerAmount <= maxWagerAmount : true
                return wagerAmountCheck &&
                       (!showOnlyFriends || friendUIDs.contains(challenge.senderID))
            } ?? viewModel.publicPendingChallenges
        }
        // Update your view model's state based on 'filtered' results
    }
}



struct challengeCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    @State private var showRulesPage = false
    @State private var showFilterView = false
    @Binding var poolBucks: Double
    
    @State var selectedSport: String = "All"
    @State var maxWagerAmount: Double = 0
    @State var showOnlyFriends: Bool = false
    @State var filtered: [DirectChallengeTicket] = []
    
    var body: some View {
        VStack {
            HStack (spacing: 10) {
                VStack {
                    HStack {
                        NavigationLink(destination: {tabBarView(selection: .book)}, label: {
                            Text("Create a challenge +")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                                .foregroundColor(.white)
                        })
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                
                VStack {
                    Button {
                        showRulesPage.toggle()
                    } label: {
                        HStack {
                            Text("What are challenges?")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                                .foregroundColor(.white)
                            
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                
                VStack {
                    HStack {
                        NavigationLink {
                            purchaseCurrencyView()
                                .background(K.finalColor.backgroundBlue)
                        } label: {
                            HStack (spacing: 7.5){
                                Text("Deposit/Withdraw")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                                    .foregroundColor(.white)
                            }
                            
                        }
                        
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, maxHeight: 90)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
                
                
            }.padding(.horizontal,15)
            ZStack{
                HStack {
                    Spacer()
                    Text("Public Challenges Available")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(.white)
                        .padding(.top)
                    Spacer()
                }
                HStack{
                    Spacer()
                    Button(action: {showFilterView.toggle()}, label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                    })
                    
                }
            }
            ScrollView {
                VStack(spacing: 0){
//                    ForEach(viewModel.publicPendingChallenges, id: \.customID) { challenge in
//                        if challenge.status == "pendingPublicAcceptance" {// challenge has begun
//                            if Date() < challenge.gameCommenceTime.dateValue() {
//                                publicWager(viewModel: viewModel, challenge: challenge)
//                            }
//                        }
//
//                    }
//                    ForEach(viewModel.sportsWithChallenges.keys.sorted(), id: \.self) { sportKey in
//                        SportSectionView(viewModel: viewModel, challenges: Binding(get: {
//                                                              viewModel.sportsWithChallenges[sportKey] ?? []
//                                                          }, set: { _ in }),
//                                                         isExpanded: Binding(get: {
//                                                              viewModel.expandedSections[sportKey] ?? false
//                                                          }, set: { newValue in
//                                                              viewModel.expandedSections[sportKey] = newValue
//                                                          }),
//                                                         sportName: sportKey)
//                                    }
                    ForEach(filtered, id: \.customID) { challenge in
                        // Replace `ChallengeView` with whatever view you use to display each challenge
                        if challenge.status == "pendingPublicAcceptance" {
                            if Date() < challenge.gameCommenceTime.dateValue() {
                                publicWager(viewModel: viewModel, challenge: challenge)
                                    .padding(.horizontal,-10)
                            }
                        }
                    }
                }.padding(.bottom, 75)
            }.refreshable {
                viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {
                    poolBucks = StaticUserData.shared.currentUser.poolBucks
                }
                viewModel.fetchPublicChallenges {
                    viewModel.populateSportsChallenges()
                }
            }
            .onAppear() {
                viewModel.fetchUserCoinsAndBucks(userID: StaticUserData.shared.currentUser.id!) {
                    poolBucks = StaticUserData.shared.currentUser.poolBucks
                }
                viewModel.fetchPublicChallenges {
    //                viewModel.fetchChallengeGames(matchingIDs: viewModel.gamesIDsInChallenges) { games in
    //                    viewModel.gamesInChallenges = games ?? []
    //                }
                    filtered = viewModel.publicPendingChallenges
                    viewModel.populateSportsChallenges()
                }
            }
            .popup(isPresented: $showRulesPage) {
                Text("The popup")
                explanationView(pageSelected: 1)
                    .frame(height: 600)
                
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
            .popup(isPresented: $showFilterView) {
                Text("The popup")
                FilterSheetView(selectedSport: $selectedSport, maxWagerAmount: $maxWagerAmount, showOnlyFriends: $showOnlyFriends, filtered: $filtered, viewModel: viewModel, friendUIDs: [])
//                    .frame(height: 800)
                
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
}


struct SportSectionView: View {
    @ObservedObject var viewModel: challengeViewModel
    @Binding var challenges: [DirectChallengeTicket] // Challenges for this sport
    @Binding var isExpanded: Bool // Binding to the expanded state of this section
    var sportName: String
    
    var body: some View {
        VStack {
            HStack {
                Text(sportName)
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down").foregroundStyle(.white) // Dropdown icon
                    .onTapGesture {
                        // Toggle expanded state when the icon is tapped
                        withAnimation{
                            isExpanded.toggle()
                        }
                    }
            }.padding()
            
            if isExpanded {
                ForEach(challenges, id: \.customID) { challenge in
                    // Replace `ChallengeView` with whatever view you use to display each challenge
                    if challenge.status == "pendingPublicAcceptance" {
                        if Date() < challenge.gameCommenceTime.dateValue() {
                            publicWager(viewModel: viewModel, challenge: challenge)
                                .padding(.horizontal,-10)
                        }
                    }
                }
            }
        }
        .background(K.finalColor.backgroundBlue)
        .cornerRadius(8)
        .shadow(radius: 2)
        
        .overlay(
            RoundedRectangle(cornerRadius: 8) // Match cornerRadius with the VStack's cornerRadius
                .stroke(K.finalColor.blueGray, lineWidth: 1) // White line as border
        )
        .padding(.horizontal)
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
    @State private var selectedUser: User? = nil

    
    
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
                        if maxSliderValue == -99 && currencyChosen == "poolBucks" {
                            HStack {
//                                Image("poolBuck")
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
                                Spacer()
                                Text("Purchase or Win poolBucks to send challenges")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center) // Centers the text
                                    .lineLimit(nil) // Allows text to wrap across multiple lines
                                Spacer()
//                                Image("poolBuck")
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
                            }.frame(height: 100).background(K.finalColor.cardBlue).cornerRadius(7.5)
                            .padding(.horizontal, 14)
                            .padding(.vertical)
                        } else if currencyChosen == "poolCoins" {
                               Text("Coming soon!")
                                   .font(.custom(K.customFonts.lexendDecaMedium, size: 30))
                                   .foregroundColor(.white)
                        } else {
                            payoutHeader(currencyChosen: $currencyChosen, wagerAmount: $wagerAmount)
                            
                        }
                    }.padding(.top, 10)

                    if maxSliderValue != -99 && currencyChosen == "poolBucks"{
                        VStack {
                            HStack{
                                Text("Adjust Bet Amount")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Slider(value: $wagerAmount, in: 0.0...maxSliderValue, step: 1) { editing in
                                
                            }.accentColor(.white)
                            
                        }.padding(.horizontal,20)
                            .padding(.vertical,10)
                    }
 
                    
                    searchBarView(keyword: keywordBinding)
                            
                    ScrollView {
                        ForEach(viewModel.queriedUsers, id: \.id) { user in
                            if user.id != StaticUserData.shared.currentUser.id {
                                userBio(user: user, selectedUserID: $selectedUserID, selectedUserUsername: $opponentUsername, selectedUser: $selectedUser)
                                    .padding(.vertical,3)
                                    .padding(.horizontal,14)
                            }
                        }
                    }.frame(height: 115)
                        .padding(.vertical)
                    
                    VStack {
                        CustomStepper2(value: $oneLegNum, range: 0...3, title: "\(oneLegNum == 1 ? "Bet to Fill" : "Bets to Fill")")
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
        let defaultValue: Double = -99 // Set a default or minimum value for the slider

        if currencyChosen == "poolCoins" {
            return StaticUserData.shared.currentUser.poolCoins > 0 ? StaticUserData.shared.currentUser.poolCoins : defaultValue
        } else {
            return StaticUserData.shared.currentUser.poolBucks > 0 ? StaticUserData.shared.currentUser.poolBucks : defaultValue
        }
    }
}


struct payoutHeader: View {
    @Binding var currencyChosen: String
    @Binding var wagerAmount: Double
    
    init(currencyChosen: Binding<String>, wagerAmount: Binding<Double>) {
        self._currencyChosen = currencyChosen
        self._wagerAmount = wagerAmount
    }
    
    // Custom initializer for non-binding (constant) parameters
    init(currencyChosen: String, wagerAmount: Double) {
        self._currencyChosen = Binding.constant(currencyChosen)
        self._wagerAmount = Binding.constant(wagerAmount)
    }
    
    var body: some View {
        HStack (spacing: 23){
            VStack {
                HStack {
                    Spacer()
                    Text("Risk")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 13))
                        .foregroundColor(.white)
                        //.padding(.top, 2)
                    Spacer()
                        
                }.frame(height: 15)
                    .background(.gray)
                    
                HStack {
                    Image(currencyChosen == "poolCoins" ? "poolCoin" : "poolBuck")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("\(String(format: "%.2f", wagerAmount))")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                        .foregroundColor(.white)
                }.padding(.top, 6)
                Spacer()
            }.frame(width: 160, height: 75)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
            VStack {
                HStack {
                    Spacer()
                    Text("Payout")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 13))
                        .foregroundColor(.white)
                    Spacer()
                }.frame(height: 15)
                    .background(.gray)
                HStack {
                    Image(currencyChosen == "poolCoins" ? "poolCoin" : "poolBuck")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("\(String(format: "%.2f", wagerAmount*0.952))")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                        .foregroundColor(.white)
                }.padding(.top, 6)
                Spacer()
            }.frame(width: 160, height: 75)
                .background(K.finalColor.cardBlue)
                .cornerRadius(7.5)
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
                                gameRowImages(game: game, viewModel: viewModel, isSelected: viewModel.isGameSelected(gameId: game.idd!), searchTerm: $searchTerm)

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

struct searchBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        HStack {
            
            
            TextField("Search", text: $keyword)
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
                .textInputAutocapitalization(.never)
//                .keyboardType(.URL)
                .disableAutocorrection(true)
                
            
            //.padding(.vertical, 5)
           
//                .onChange(of: username) { newUsername in
//                    username = newUsername.lowercased()
//                    viewModel.checkUsernameAvailability(potentialUsername: username) {}
//                    
//                }
//                .placeholder(when: username.isEmpty, placeholder: {
//                    Text("Username").foregroundColor(.gray)
//                })
//                .foregroundColor(.white)
//                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
//                .accentColor(.white)
//                .textInputAutocapitalization(.none)  // Consider changing this to .none if you always want lowercase
//                .disableAutocorrection(true)
            
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 15))
        .frame(width: 345, height: 44)
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .cornerRadius(7.5)
    }
}

struct userBio: View {
    var user: User
    
    @State var checked = false
    @Binding var selectedUserID: String
    @Binding var selectedUserUsername: String
    @Binding var selectedUser: User?
    
    var body: some View {
        Button {
            selectedUser = user
            selectedUserUsername = ""
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
                    .frame(width: 345, height: 44)
                    .background(selectedUserID == user.id ? K.finalColor.otherPurple.opacity(0.35) : K.finalColor.cardBlue)
                    .cornerRadius(10)
            }
//            .onTapGesture {
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                print("tapped also")
//            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
