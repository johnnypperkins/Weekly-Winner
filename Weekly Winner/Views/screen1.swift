//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase

struct UserProfileView: View {
    @StateObject var authenticationVM = authenticationViewModel()
    @StateObject var bookVM = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    @StateObject var groupsVM = groupsViewModel()
    @StateObject var countdownTimer = CountdownTimer()
    
    var body: some View {
        VStack(spacing: 20) {
            VStack (spacing: 0){
                HStack {
                    Text("Weekly Wager")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.white)
                        .font(.largeTitle)
                        .padding(.bottom)
                }.frame(height: 50) // Adjust the height as needed
                    .background(K.steelBlue)
                HStack {
                    Text("\(countdownTimer.timeRemaining)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(K.steelBlue)
                        .font(.subheadline)
                        //.padding(.bottom)
                }.frame(height:25) // Adjust the height as needed
                    .background(K.veryLightGray)
            }
            
            ProfileHeaderView(authVM: authenticationVM)
                .padding(.top, 10)
                .padding(.horizontal)
            
            groupStatusView(groupsVM: groupsVM)
                .padding(.horizontal)
                .padding(.horizontal)
            //Divider()
                .padding(.horizontal, 20)
            
            MostPopularBetsView(bookVM: bookVM)
                .padding(.horizontal)
                .padding(.horizontal)
            Spacer()

        }
        .onAppear() {
            authenticationVM.fetchUser()
            groupsVM.fetchUserTickets() {}
            bookVM.fetchMostPopularBets()
        }
    }
}

struct ProfileHeaderView: View {
    @StateObject var authVM: authenticationViewModel
    var body: some View {
        HStack(spacing: 17.5) {
            Spacer() // Add a Spacer to center the text
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            Text("\(authVM.currUser?.username ?? "")")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(K.steelBlue)
            Spacer() // Add a Spacer to center the text
        }
        .frame(height: 65)
        .background(Color.white)
        .cornerRadius(5)
        //.shadow(radius: 10)
        //.padding()
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
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0...bookVM.mostPopularBets.count, id: \.self) { index in
                if index == 0 {
                    HStack{
                        Spacer()
                        Text("Most Popular Bets")
                            .font(.headline)
                        Spacer()    //.frame(width: .infinity, alignment: .center)
                    }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        //.padding(.center)
                        .background(K.veryLightGray)
                } else {
                    HStack {
                        PopularBetView(index: index, bookVM: bookVM)
                    }.padding(EdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0))
                        .padding(.horizontal)
                        .background(K.veryLightBlue.opacity(0.5))
                }
            }
        }
        .cornerRadius(5)
    }
}

struct PopularBetView: View {
    var index: Int
    @StateObject var bookVM: bookViewModel
    private var extra: String {
        if bookVM.mostPopularBets[index-1].betType == .over {
            return "o"
        } else if bookVM.mostPopularBets[index-1].betType == .under {
            return "u"
        } else {
            if bookVM.mostPopularBets[index-1].betLine >= 0 {
                return "+"
            }
        }
        return ""
    }

    var body: some View {
        HStack {
            Text("\(index). \(bookVM.mostPopularBets[index-1].teamName)").frame(width: 225, alignment: .leading)
            Spacer()
            Text("\(extra)\(bookVM.mostPopularBets[index-1].betLine)").frame(width: 60, alignment: .trailing)
        }
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
