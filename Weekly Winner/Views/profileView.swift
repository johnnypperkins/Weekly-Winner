//
//  screen5.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Kingfisher

struct profileView: View {
    
    @ObservedObject var viewModel: profileViewModel
    @State var scrollViewOffset: CGFloat = 0
    //@State private var isShowingEditProfile: Bool = false
    @State private var isProfileEditing = false
    @Environment(\.dismiss) private var dismiss
    private var user: User
    
    @State private var showDropdown = false
    @State private var selectedGroup = "global"
    var onOptionSelected: ((_ option: Ticket) -> Void)?
    
    
    init(user: User) {
        viewModel = profileViewModel(user: user)
        self.user = user
        
        if viewModel.user.isCurrentUser == false{
            
        }
    }
    
    var body: some View {
        NavigationStack {
                VStack {
                    NavigationStack{
                        VStack{
                            ZStack {
                                Text("My Profile")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                                    .foregroundColor(.white)
                                HStack{
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

                                    
                                }
                            }.padding(.top, 50).padding(.horizontal) // has to be at least 50 so doesnt interfere with safe area
                            
                            ProfileStatsView(viewModel: viewModel, user: user)
                                .padding(.vertical)
                                .padding(.horizontal,20.5)
                            Spacer()
                            
                            
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("Statistics")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(.horizontal)
                                    
                                    groupStats(allBets: viewModel.allDailyBets, allTickets: viewModel.allDailyTickets)
                                        .padding(.all,16)
                                }.padding(.bottom, 75)
                            
                        }
                    }.padding(.top)
                    
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                .onAppear() {
                    viewModel.fetchUser()
                    //viewModel = profileViewModel(user: user)
                }
            }
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        //}
    }
    
}

struct groupStats: View {
//    let stat1: Int?
//    let stat2: Int?
//    let stat3: String
//    let stat4: String
    let allBets: [Bet]
    let allTickets: [Ticket]
    var winsCount: Int {
        var num = 0
        for bet in allBets {
            if bet.result == .win {
                num = num + 1
            }
        }
        return num
    }

   // @ObservedObject var viewModel: profileViewModel
  var body: some View {
      VStack() {
        HStack() {
          Text("Bets Placed")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
            Text("\(allBets.count)")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 13)
          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
          
          HStack() {
            Text("Bets Won")
              .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
              .foregroundColor(.white)
              
              Spacer()
              
              Text("\(winsCount)")
              .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
              .foregroundColor(.white)
          }
          .padding(.horizontal)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 13)

          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
        HStack() {
          Text("Average Odds Placed")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
            Text("\(!allBets.isEmpty ? percentageToML(percentage: allBets.map { Double($0.betOdds) }.reduce(0.0, +) / Double(allBets.count)) : "n/a")")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }.padding(.horizontal)
              .padding(.vertical, 13)
        .frame(maxWidth: .infinity)
          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
        HStack() {
          Text("Bet Score")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
            /*
             if (betData.result === "win") {
                 totalBetsWon++;
                 totalBetScore += ((1 / betData.betOdds)*100 - 100);
             }
             */
            
          Text("\(String(format: "%.2f", returnTotalBetScore(allBets: allBets)))")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }.padding(.horizontal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
      }
      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
      .cornerRadius(10)
  }
}

func returnTotalBetScore(allBets: [Bet]) -> Double {
    var totalBetScore: Double = 0.0
    for bet in allBets {
        if bet.result == .win {
            totalBetScore = totalBetScore + (1 / Double(bet.betOdds)*100 - 100);
        }
    }
    if !allBets.isEmpty {
        return totalBetScore / Double(allBets.count)
    } else {
        return 0
    }
}

struct Dropdown: View {
    var options: [Ticket]
    var onOptionSelected: ((_ option: Ticket) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<self.options.count, id: \.self) { num in
                    if num != 0{
                        Divider()
                            .bold()
                    }
                    DropdownRow(option: options[num], onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(minHeight: CGFloat(options.count) * 40, maxHeight: CGFloat(options.count) * 40)
        .padding(.vertical, 5)
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
                
        )
    }
}

struct DropdownRow: View {
    var option: Ticket
    var onOptionSelected: ((_ option: Ticket) -> Void)?

    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.groupName)
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                    .foregroundColor(Color.white)
                
                Spacer()
            }
        }.frame(height: 30)
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}



struct SideMenuButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2) // Make the button text bigger
            .foregroundColor(.white)
            .padding(.bottom) // Add padding to create space between buttons
    }
}

struct ProfileStatsView: View {
    @StateObject var viewModel: profileViewModel
    var user: User

    var body: some View {

        HStack {
            Spacer()
            profilePicDisplayView(dimension: 80, picURL: viewModel.profileImageURLHolder)
            VStack(alignment: .leading, spacing: 0) {
                
                    Text(user.username)
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 20))
                        .foregroundColor(.white)
                    
                
                    
                    Text("Joined: " + formatDateMMDDYY(from: user.dateJoined))
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 12))
                        .foregroundColor(.gray)
                    
                
                
            }
            Spacer()
        }
    }
}


struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}


struct ContactView: View {
    var body: some View {
        VStack {
            Text("Contact Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Contact", displayMode: .inline)
    }
}

//struct Screen5_Previews: PreviewProvider {
//    static var previews: some View {
//        profileView(user: <#T##User#>)
//    }
//}

