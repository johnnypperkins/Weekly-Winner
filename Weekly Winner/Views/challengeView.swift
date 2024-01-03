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

struct challengeView: View {
    @State var tabSelected = 0
    
    @ObservedObject var challengeVM = challengeViewModel()
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Available"
        case 1: return "Pending"
        case 2: return "Completed"
        default: return "PoolCoins"
        }
    }

    private func offsetForSelectedTab() -> CGFloat {
        let baseOffset: CGFloat = -212.5
        let tabWidth: CGFloat = 85
        let offset = baseOffset + CGFloat(tabSelected + 1) * tabWidth
        return offset
    }

    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue
            VStack {
                VStack (spacing: 4) {
                    HStack (spacing: 0) {
                        ForEach(0..<4, id: \.self) { index in
                            Button(action: {
                                tabSelected = index
                            }) {
                                Text(tabTitle(for: index))
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                    .foregroundColor(.white)
                                    .frame(width: 85, height: 35, alignment: .center)
                                    .cornerRadius(5)
                            }
                        }
                    }.padding(.top, 35)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 75, height: 3)
                        .cornerRadius(1)
                        .offset(x: offsetForSelectedTab(), y: 0)
                        .animation(.easeInOut(duration: 0.35))
                }.padding(.top, 40)
                 .cornerRadius(7.5)
                
                challengeCardView(viewModel: challengeVM)
                    .padding(.top, 20)
                
                Spacer()
            }.background(K.finalColor.backgroundBlue)
        }
    }

 
}




struct challengeCardView: View {
    @ObservedObject var viewModel: challengeViewModel
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: {challengePage1(viewModel: viewModel)}, label: {
                    Text("Create a challenge +")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                        .foregroundColor(.white)
                })
            }
        }
        .frame(width: 250, height: 150)
        .background(K.finalColor.cardBlue)
        .cornerRadius(7.5)
    }
}

struct challengePage1: View {
    @State var currencyChosen = "PoolBucks"
    @State var opponentUsername = ""
    @State private var selectedUserID: String?
    @State private var wagerAmount: Double = 0
    let maxWagerAmount: Double = 200
    
    @State private var oneLegNum: Int = 0
    @State private var twoLegNum: Int = 0
    @State private var threeLegNum: Int = 0
    @State private var fourLegNum: Int = 0
    @State private var fiveLegNum: Int = 0
    
    @ObservedObject var viewModel: challengeViewModel
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                opponentUsername
            },
            set: {
                opponentUsername = $0
                viewModel.fetchUser(from: opponentUsername)
            }
        )
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue
                VStack {
                    
                    HStack (spacing: 20){
                        Button(action: {
                            if currencyChosen != "PoolBucks" {
                                currencyChosen = "PoolBucks"
                            }
                        }) {
                            HStack {
                                Text("PoolBucks")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "PoolBucks" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                        Button(action: {
                            if currencyChosen != "PoolCoins" {
                                currencyChosen = "PoolCoins"
                            }
                        }) {
                            HStack {
                                Text("PoolCoins")
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 150, height: 50, alignment: .center)
                            .background(currencyChosen == "PoolCoins" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                            .cornerRadius(5)
                        }
                    }.padding(.top, 40)
                    VStack {
                        HStack{
                            Text("Enter Bet Amount")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.1f", wagerAmount))
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                        }
                        Slider(value: $wagerAmount, in: 0...maxWagerAmount, step: 1) { editing in
                            
                        }
                        .accentColor(.white)
                        .background(Color(red: 0.77, green: 0.85, blue: 0.98).blur(radius: 15).opacity(0.60))
                        
                        
                    }.padding(.horizontal,20)
                        .padding(.vertical,10)
                    
                            searchBarView(keyword: keywordBinding)
                            
                            
//                        Text((viewModel.opponentUsernameExists && opponentUsername != "") ? "Available" : "Unavailable")
//                            .foregroundColor((viewModel.opponentUsernameExists && opponentUsername != "") ? K.finalColor.winningGreen : K.finalColor.deleteRed)
//                            .padding(4)
//                            .background((viewModel.opponentUsernameExists && opponentUsername != "") ? K.finalColor.winningGreen.opacity(0.6) : K.finalColor.deleteRed.opacity(0.6))
                        
//                    .onChange(of: opponentUsername) { newValue in
//                        viewModel.checkUsernameAvailable(username: newValue) {_,_ in
//                        }
//                    }
                    ScrollView {
                        ForEach(viewModel.queriedUsers, id: \.id) { user in
                            
                            userBio(user: user, selectedUserID: $selectedUserID)
                                .padding(.vertical,3)
                                .padding(.horizontal,14)
                        }
                    }
                    Spacer()
                    VStack {
                        CustomStepper(value: $oneLegNum, range: 0...8, title: "1 Legs")
                            .padding(.horizontal,14)
                        CustomStepper(value: $twoLegNum, range: 0...5, title: "2 Legs")
                            .padding(.horizontal,14)
                        CustomStepper(value: $threeLegNum, range: 0...4, title: "3 Legs")
                            .padding(.horizontal,14)
                        CustomStepper(value: $fourLegNum, range: 0...3, title: "4 Legs")
                            .padding(.horizontal,14)
                        CustomStepper(value: $fiveLegNum, range: 0...2, title: "5 Legs")
                            .padding(.horizontal,14)
                    }
                    
      
                    
                    NavigationLink(destination: {challengePage2(
                        viewModel: viewModel, currencyChosen: currencyChosen,
                                                    opponentUsername: opponentUsername,
                                                    selectedUserID: selectedUserID,
                                                    wagerAmount: wagerAmount).background(K.finalColor.backgroundBlue)}, label: {
                        HStack{
                            Spacer()
                            Text("Place Bet")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(Color(red: 0.31, green: 0.57, blue: 1))
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,20)
                    })
                }
            }
        }.background(K.finalColor.backgroundBlue)
    }
}
    
struct challengePage2: View {
    @ObservedObject var viewModel: challengeViewModel
    
    let currencyChosen: String
    let opponentUsername: String
    let selectedUserID: String?
    let wagerAmount: Double
    
    @State var challengeFormat = "timeBased"
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue
                VStack (spacing: 4) {
                    HStack (spacing: 0) {
                        Button(action: {
                            challengeFormat = "timeBased"
                        }) {
                            Text("Time Based")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40, alignment: .center)
                                .cornerRadius(5)
                        }
                        
                        Button(action: {
                            challengeFormat = "gameBased"
                        }) {
                            Text("Game Based")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 17))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 40, alignment: .center)
                                .cornerRadius(5)
                        }
                    }.padding(.top, 35)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 120, height: 3)
                        .cornerRadius(1)
                        .offset(x: challengeFormat == "timeBased" ? -75 : 75, y: 0)
                        .animation(.easeInOut(duration: 0.35))
                    
                    if challengeFormat == "timeBased" {
                        timeBasedView()
                    } else if challengeFormat == "gameBased" {
                        gameBasedView(viewModel: viewModel)
                            .padding(.top, 7.5)
                    }
                    
                    Spacer()
                }.padding(.top, 40)
                 .cornerRadius(7.5)
            }
        }
    }
}

struct searchBarView: View {
    @Binding var keyword: String
    
    var body: some View {
        HStack {
            TextField("Search", text: withAnimation{$keyword})
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

struct timeBasedView: View {
    var body: some View {
        Text("hello")
    }
}

struct gameBasedView: View {
    
    @State var searchTerm = ""
    
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
                            gameRowImages(game: game)
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
    @State var titleStringH: String = ""
    @State var titleStringA: String = ""
    
    
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
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
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
    @Binding var selectedUserID: String?
    
    var body: some View {
        Button {
            withAnimation {
                if selectedUserID == user.id {
                    selectedUserID = nil // Deselect if already selected
                } else {
                    selectedUserID = user.id // Select the user
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
                    //        .opacity(ticket.isEnabled || ticket.groupAdmin == Auth.auth().currentUser?.uid ? 1 : 0.66)
                    .padding(.vertical, 10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                    .background(selectedUserID == user.id ? K.finalColor.otherPurple.opacity(0.35) : K.finalColor.cardBlue)
                    .cornerRadius(10)
                    //.overlay(ownCard ? RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1) : RoundedRectangle(cornerRadius: 10).stroke(Color.clear, lineWidth: 0))
                    //.shadow(color: ownCard ? Color.white : Color.clear, radius: ownCard ? 2.5 : 0, x: 0, y: 0)
                    
                    
                    
                    //        .onAppear {
                    //            isEnabled = ticket.isEnabled
                    //            fetchUserProfilePic(uid: ticket.uid) { (profileImageUrl, error) in
                    //                if let error = error {
                    //                    print("Error fetching profile image URL: \(error)")
                    //
                    //                } else if let profileImageUrl = profileImageUrl {
                    //                   //print("Profile image URL: \(profileImageUrl)")
                    //                    self.profileImageURL = profileImageUrl
                    //                }
                    //            }
                    //        }
                }
            }
        }
    }
