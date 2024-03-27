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
                            if user.id! == StaticUserData.shared.currentUser.id {
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
                            }
                            else{
                                HStack {
                                    Button {
                                        // 2
                                        dismiss()
                                        
                                    } label: {
                                        HStack {
                                            Image(systemName: "chevron.backward")
                                            
                                                .resizable()
                                                .foregroundColor(.white)
                                                .frame(width: 10,height: 15)
                                        }   .padding(.leading)
                                    }
                                    Spacer()
                                }.padding()
                            }
                        
                            ProfileStatsView(viewModel: viewModel, user: user)
                                .padding(.vertical)
                                .padding(.horizontal,20.5)
                            HStack{
                                NavigationLink(destination: {friendsList(friends: viewModel.friends)}, label: {
                                VStack{
                                    Text("Friends")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 15).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                
                                        Text("\(viewModel.friends.count)")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18).weight(.medium))
                                            .foregroundColor(.white)
                                    
                                }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                                   }).id(UUID())
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(minWidth: 0,maxWidth: 0.5, minHeight: 0, maxHeight: .infinity)
                                  .overlay(Rectangle()
                                  .stroke(.white, lineWidth: 0.4))
                                  .padding(.horizontal)
                                  .padding(.vertical)
                                VStack{
                                    Text("Past Tickets")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 15).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                
                                        Text("\(viewModel.pastDayTicketsCount)")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18).weight(.medium))
                                            .foregroundColor(.white)
                                    
                                }.frame(maxWidth: .infinity)
                                    
                                    .padding(.vertical, 13)
//                                                   }).id(UUID())
                            }
                                .frame(maxWidth: 300)
                                .frame(maxHeight: 60)
                                .padding(.horizontal)
                      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                      .cornerRadius(10)
                            if user.id! == StaticUserData.shared.currentUser.id {
                                NavigationLink {
                                    addFriendsView()
                                } label: {
                                    HStack{
                                        Image(systemName: "person.badge.plus.fill")
                                            .foregroundStyle(.white)
                                            .frame(width: 25, height: 25)
                                            .padding()
                                        
                                        Text("Add New Friends")
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 18).weight(.light))
                                            .foregroundColor(.white)
                                        
                                    }.frame(maxWidth: 300)
                                        .frame(maxHeight: 40)
                                        .padding(.horizontal)
                                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                        .cornerRadius(10)
                                    
                                }.id(UUID())
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                            }
//                            else{
//                                Button(action: {
//                                    if viewModel.isFollow == true {
//                                        viewModel.unfollow()
//                                    } else {
//                                        viewModel.follow()
//                                    }
//                                }, label: {
//                                    HStack {
//                                        Text(viewModel.isFollow ? "Unfollow" : "Follow")
//                                            .font(.custom(K.customFonts.lexendDecaMedium, size: 18))
//                                            .foregroundColor(viewModel.isFollow ? K.finalColor.cardBlue : K.finalColor.titleBlue)
//                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
//                                    }
//                                    .frame(width: 150, height: 40) // Adjusted for a more typical pill shape
//                                    .background(viewModel.isFollow ? K.finalColor.titleBlue : K.finalColor.cardBlue)
//                                    .cornerRadius(20) // Use 20 or adjust as needed for the pill shape, or better yet, use .clipShape(Capsule()) as shown below
//                                    .clipShape(Capsule())
//                                    .overlay(
//                                        Capsule()
//                                            .stroke(Color.white, lineWidth: 1)
//                                    )
//                                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 2, y: 2)
//                                    .shadow(color: .white.opacity(0.5), radius: 1, x: -2, y: -2)
//                                })
//                                .padding()
//                            }
                        
                            
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
                                        .padding(.horizontal,16)
                                        .padding(.vertical, 10)
                                }.padding(.bottom, 75)
                            
                        }
                    }.padding(.top)
                    
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                .onAppear() {
                    viewModel.fetchUser()
                    viewModel.countPastDayTickets()
                    viewModel.importFriends()
                    //viewModel = profileViewModel(user: user)
                }
        }.navigationBarBackButtonHidden()
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        //}
    }
    
}

struct friendsList: View {
    var friends: [User]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack{
            HStack {
                Button {
                    // 2
                    dismiss()
                    
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .foregroundColor(.white)
              
                            .frame(width: 10,height: 15)
                    }.padding(.leading)
                }
                Spacer()
            }.padding()
            ScrollView {
                if friends == [] {
                   
                }
                ForEach(friends, id: \.id) { user in
                    NavigationLink(destination: {profileView(user: user)}, label: {
                            profileBarView(user: user)
                            
                    }).id(UUID())
                }
            }.navigationBarBackButtonHidden(true)
        }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

struct profileBarView: View {
    
    var user: User
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.2))
            HStack{
                profilePicDisplayView(dimension: 50, picURL: user.profileImageUrl)
//                KFImage(URL(string: user.profileImageUrl))
//                    .resizable()
//                    .cornerRadius(25)
//                    .frame(width: 50, height: 50, alignment: .leading)
                    
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(user.firstName)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                            .foregroundColor(.white).padding(.trailing,1)
                        
                        Text("\(user.lastName)")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                            .foregroundColor(.white)
                    }
                    Text("@\(user.username)")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .frame(alignment: .leading)
            .padding(.horizontal)
        }.background(K.finalColor.cardBlue)
        .frame(maxWidth: .infinity, minHeight: 80)
        .cornerRadius(13)
        .padding(.horizontal)
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
        } else if bet.result == .loss {
            totalBetScore = totalBetScore - 100;
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
                if viewModel.user.id != StaticUserData.shared.currentUser.id {
                    Button(action: {
                        if viewModel.isFollow == true {
                            viewModel.unfollow()
                        } else {
                            viewModel.follow()
                        }
                    }, label: {
                        HStack {
                            Text(viewModel.isFollow ? "Friends" : "Add Friend")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 2.5)
                                .padding(.vertical, 1)
                            
                        }
                        .background(viewModel.isFollow ? K.finalColor.winningGreen : K.finalColor.potentialOrange)
                        .cornerRadius(2.5)
                        .padding(.top, 3)
                    })
                }
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

