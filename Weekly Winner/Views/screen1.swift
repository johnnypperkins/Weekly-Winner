//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import Kingfisher

struct UserProfileView: View {
    @StateObject var authenticationVM = authenticationViewModel()
    @StateObject var bookVM = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    @StateObject var groupsVM = groupsViewModel()
    @StateObject var countdownTimer = CountdownTimer()
    
    var body: some View {
        VStack() {
            
            
            ProfileHeaderView(authVM: authenticationVM)
                .padding(.top, 10)
                .padding(.horizontal,16)
            
            countDown()
                .padding(.top)
            
            
            yourGroups(groupsVM: groupsVM)
                .padding(.horizontal,16)
            
             //   mostPopularBets(bookVM: bookVM)
            MostPopularBetsView(bookVM: bookVM)
                .padding(.horizontal)
                .padding(.horizontal)
            Spacer()

        }
        .background(Color(red: 0.03, green: 0.03, blue: 0.03))
        .onAppear() {
            print("appeared")
            authenticationVM.fetchUser() {
                
                print("\(UserData.shared.username) is username")
            }
            groupsVM.fetchUserTickets() {}
            bookVM.fetchMostPopularBets()
        }
    }
}

struct mostPopularBets: View {
    @ObservedObject var bookVM: bookViewModel
    
    
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
        Text("Most Popular Bets")
            .font(Font.custom("Lexend Deca", size: 24).weight(.medium))
            .foregroundColor(.white)
        LazyHStack(spacing: 20) {
            ForEach(0...bookVM.mostPopularBets.count, id: \.self) { index in
                VStack(spacing: 2.74) {
                  VStack(spacing: 3.74) {
                      if bookVM.arePopularBetsLoaded == true {
                          Text("\(bookVM.mostPopularBets[index].betLine)")
                      }
//                     PopularBetView(index: index, bookVM: bookVM)
                  }
                  .frame(width: 87.57)
                }
                .padding(
                  EdgeInsets(top: 4.56, leading: 9.12, bottom: 4.56, trailing: 9.12)
                )
                .frame(height: 83)
                .background(Color(red: 0.13, green: 0.13, blue: 0.13))
                .cornerRadius(9.12)
            }
        }
//      Text("Most Popular Bets")
//        .font(Font.custom("Lexend Deca", size: 24).weight(.medium))
//        .foregroundColor(.white)
//      VStack(alignment: .leading, spacing: 13) {
//        HStack(alignment: .top, spacing: 13) {
//          VStack(spacing: 2.74) {
//            VStack(spacing: 3.74) {
//              Text("U59")
//                .font(Font.custom("Poppins", size: 16).weight(.medium))
//                .foregroundColor(.white)
//              Text("KC Chiefs / Det Lions")
//                .font(Font.custom("Poppins", size: 12))
//                .foregroundColor(.white)
//            }
//            .frame(width: 87.57)
//          }
//          .padding(
//            EdgeInsets(top: 4.56, leading: 9.12, bottom: 4.56, trailing: 9.12)
//          )
//          .frame(height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//          HStack(spacing: 0) {
//            HStack(spacing: 0) {
//              ZStack() {
//                Text("+0")
//                  .font(Font.custom("Poppins", size: 16).weight(.medium))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: -10.50)
//                Text("Den Broncos")
//                  .font(Font.custom("Poppins", size: 12))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: 13.50)
//              }
//              .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//          }
//          .padding(
//            EdgeInsets(top: 22, leading: 9.18, bottom: 22, trailing: 8.82)
//          )
//          .frame(width: 106, height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//          HStack(spacing: 0) {
//            HStack(spacing: 0) {
//              ZStack() {
//                Text("-1")
//                  .font(Font.custom("Poppins", size: 16).weight(.medium))
//                  .foregroundColor(.white)
//                  .offset(x: 0.50, y: -10.50)
//                Text("KC Chiefs")
//                  .font(Font.custom("Poppins", size: 12))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: 13.50)
//              }
//              .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .padding(EdgeInsets(top: 0, leading: 6, bottom: 2, trailing: 5))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//          }
//          .padding(
//            EdgeInsets(top: 20, leading: 19.18, bottom: 20, trailing: 19.82)
//          )
//          .frame(width: 106, height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//        }
//        HStack(alignment: .top, spacing: 13) {
//          VStack(spacing: 2.74) {
//            VStack(spacing: 3.74) {
//              Text("U59")
//                .font(Font.custom("Poppins", size: 16).weight(.medium))
//                .foregroundColor(.white)
//              Text("KC Chiefs / Det Lions")
//                .font(Font.custom("Poppins", size: 12))
//                .foregroundColor(.white)
//            }
//            .frame(width: 87.57)
//          }
//          .padding(
//            EdgeInsets(top: 4.56, leading: 9.12, bottom: 4.56, trailing: 9.12)
//          )
//          .frame(height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//          HStack(spacing: 0) {
//            HStack(spacing: 0) {
//              ZStack() {
//                Text("+0")
//                  .font(Font.custom("Poppins", size: 16).weight(.medium))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: -10.50)
//                Text("Den Broncos")
//                  .font(Font.custom("Poppins", size: 12))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: 13.50)
//              }
//              .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//          }
//          .padding(
//            EdgeInsets(top: 22, leading: 9.18, bottom: 22, trailing: 8.82)
//          )
//          .frame(width: 106, height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//          HStack(spacing: 0) {
//            HStack(spacing: 0) {
//              ZStack() {
//                Text("-1")
//                  .font(Font.custom("Poppins", size: 16).weight(.medium))
//                  .foregroundColor(.white)
//                  .offset(x: 0.50, y: -10.50)
//                Text("KC Chiefs")
//                  .font(Font.custom("Poppins", size: 12))
//                  .foregroundColor(.white)
//                  .offset(x: 0, y: 13.50)
//              }
//              .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//            .padding(EdgeInsets(top: 0, leading: 6, bottom: 2, trailing: 5))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//          }
//          .padding(
//            EdgeInsets(top: 20, leading: 19.18, bottom: 20, trailing: 19.82)
//          )
//          .frame(width: 106, height: 83)
//          .background(Color(red: 0.13, green: 0.13, blue: 0.13))
//          .cornerRadius(9.12)
//        }
//      }
    }
    .frame(width: 343.82, height: 225);
  }
}

struct yourGroups: View {
    @StateObject var groupsVM: groupsViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Groups")
                .font(Font.custom("Lexend Deca", size: 24).weight(.medium))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(0..<groupsVM.userTickets.count, id: \.self) { index in
                        // Use your custom view or data here.
                        // Replace `Text("Item \(index)")` with your custom view
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 7) {
                                HStack(alignment: .top) {
                                    Text(groupsVM.userTickets[index].groupName)
                                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("#\(groupsVM.userTickets[index].rank)")
                                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                }
                                Image("sampleImage")
                                    .resizable()
                                    .cornerRadius(12)
                                    .foregroundColor(.clear)
                                    .scaledToFit()
                                    .frame(height: 102)
                                
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack() {
                                    Text("Potential")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(groupsVM.userTickets[index].totalPotentialWon)")
                                        .font(Font.custom("Poppins", size: 14))
                                        .foregroundColor(.white)
                                }
                                HStack() {
                                    Text("Total Won")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(groupsVM.userTickets[index].totalWon)")
                                        .font(Font.custom("Poppins", size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(10)
                        .frame(width: 135, height: 192)
                        .background(self.backgroundColor(for: index))
                        .cornerRadius(12)
                        .overlay(self.overlayShape(for: index))
                    }
                }
            }
        }
    }
    func backgroundColor(for index: Int) -> LinearGradient {
        if index % 3 == 0 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.57, green: 0.56, blue: 0.98), Color(red: 0.85, green: 0.58, blue: 0.99)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if index % 3 == 1 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.16, green: 0.62, blue: 0.52), Color(red: 0.59, green: 0.79, blue: 0.44)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.54, blue: 0.51), Color(red: 0.97, green: 0.69, blue: 0.46)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    func overlayShape(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(self.overlayColor(for: index), lineWidth: 0.50)
    }
    
    func overlayColor(for index: Int) -> Color {
        if index % 3 == 0 {
            return Color(red: 0.14, green: 0.61, blue: 0.85)
        } else if index % 3 == 1 {
            return Color(red: 0.15, green: 0.90, blue: 0.69)
        } else {
            return Color(red: 1, green: 0.74, blue: 0.60)
        }
    }
}

struct countDown: View {
    @StateObject var countdownTimer = CountdownTimer()
  var body: some View {
    ZStack() {
      VStack() {
          HStack{
              Text("Weekly Wages Countdown")
                  .font(Font.custom("Poppins-Light", size: 16))
                  .foregroundColor(.white)
              Spacer()
          }.frame(minWidth: 0, maxWidth: .infinity)
              .padding(.horizontal)
            VStack(spacing: 5) {
                Text(countdownTimer.timeRemaining)
                    .font(Font.custom("Jura-Regular", size: 28))
                    .foregroundColor(.white)
            }
          .frame(height: 32)
          
      }
      .frame(height: 71)
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 104, maxHeight: 104)
    .background(Color(red: 0.14, green: 0.61, blue: 0.85))
    .cornerRadius(10)
    .padding(.horizontal, 16)
  }
}

struct ProfileHeaderView: View {
    @StateObject var authVM: authenticationViewModel
    var body: some View {
        HStack() {
            if authVM.currUser?.profileImageUrl != nil {
                KFImage(URL(string: authVM.currUser?.profileImageUrl ?? "sampleImage"))
                    .resizable()
                    .clipShape(Circle())
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
            }else {
                Image("sampleImage")
                    .resizable()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
            }
            
            Text(authVM.currUser?.username ?? "nil")
                .font(Font.custom("Lexend Deca", size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.94))
            
                .frame(height: 30)

            Spacer()
            
            Text("FreeWager")
                .font(Font.system(size: 24).weight(.semibold))
                .foregroundColor(Color(red: 0.14, green: 0.61, blue: 0.85))
                
        }
            
    }
}


struct groupStatusView: View {
    @StateObject var groupsVM: groupsViewModel
    let frameWidth: CGFloat = 60
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...groupsVM.userTickets.count, id: \.self) { index in
                VStack(spacing: 0) {
                    HStack(spacing: 5) {
                        Text(index == 0 ? "Group" : groupsVM.userTickets[index - 1].groupName)
                            .lineLimit(1)
                            .font(index == 0 ? .headline : .body) // Set the font based on whether it's the title or not
                            .frame(minWidth: 110, maxWidth: .infinity, alignment: .leading) // Adjust the width as needed
                        Spacer()
                        HStack(spacing: 0) {
                            Text(index == 0 ? "PW" : String(groupsVM.userTickets[index - 1].totalPotentialWon ))
                                .font(index == 0 ? .headline : .body) // Set the font based on whether it's the title or not
                                .frame(width: frameWidth, alignment: .leading) // Adjust the width as needed
                                .foregroundColor(index == 0 ? Color.black : K.darkMidnightBlue)
                            Text(index == 0 ? "TW" : String(groupsVM.userTickets[index - 1].totalWon ))
                                .font(index == 0 ? .headline : .body) // Set the font based on whether it's the title or not
                                .frame(width: frameWidth, alignment: .leading) // Adjust the width as needed
                                .foregroundColor(index == 0 ? Color.black : K.lightMoneyGreen)
                            Text(index == 0 ? "Rank" : String(groupsVM.userTickets[index - 1].rank))
                                .font(index == 0 ? .headline : .body) // Set the font based on whether it's the title or not
                                .frame(width: frameWidth, alignment: .center) // Adjust the width as needed
                        }
                    }
                    .padding(index == 0 ? EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0) : EdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0))
                    .padding(.leading) // Add padding to the left of the HStack
                    .background(index != 0 ? K.veryLightBlue.opacity(0.5) : K.veryLightGray)
                }
            }
        }.cornerRadius(5)
    }
}

struct MostPopularBetsView: View {
    @StateObject var bookVM: bookViewModel
    var body: some View {
        VStack{
            Text("Most Popular Bets")
                    .font(Font.custom("Lexend Deca", size: 24).weight(.medium))
                    .foregroundColor(.white)
            LazyHStack{
                ForEach(0...bookVM.mostPopularBets.count/2, id: \.self) { index in
                    if index != 0 {
                        PopularBetView(index: index, bookVM: bookVM)
                    }
                }
            }
            .padding(.top)
            LazyHStack{
                ForEach(bookVM.mostPopularBets.count/2...bookVM.mostPopularBets.count, id: \.self) { index in
                    if index != bookVM.mostPopularBets.count/2 {
                        PopularBetView(index: index, bookVM: bookVM)
                    }
                }
            }
        }
    }
}


struct PopularBetView: View {
    var index: Int
    @StateObject var bookVM: bookViewModel
    private var extra: String {
        if bookVM.mostPopularBets[index-1].betType == .over {
            return "O"
        } else if bookVM.mostPopularBets[index-1].betType == .under {
            return "U"
        } else {
            if bookVM.mostPopularBets[index-1].betLine >= 0 {
                return "+"
            }
        }
        return ""
    }

    var body: some View {
        
        VStack(spacing: 1) {
            HStack{
                Text("#\(index)")
                Spacer()
            }.frame(alignment: .top)
            VStack(spacing: 3.74) {
                Text("\(extra)\(bookVM.mostPopularBets[index-1].betLine)")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.white)
                Text("\(bookVM.mostPopularBets[index-1].teamName)")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(.white)
            }
            .frame(width: 87.57)
        }
        .padding(
            EdgeInsets(top: 4.56, leading: 9.12, bottom: 4.56, trailing: 9.12)
        )
        .frame(height: 83)
        .background(Color(red: 0.13, green: 0.13, blue: 0.13))
        .cornerRadius(9.12)
    }
    
}

struct ClockView: View {
    @StateObject var countdownTimer: CountdownTimer
    var body: some View {
        HStack {
            Spacer()
            Text("\(countdownTimer.timeRemaining)")
            Spacer()
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
