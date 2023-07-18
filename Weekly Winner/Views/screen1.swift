//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject var authenticationVM = authenticationViewModel()
    @StateObject var bookVM = bookViewModel()
    @StateObject var ticketVM = ticketViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            ProfileHeaderView(authVM: authenticationVM)
                .padding(.top, 20)
            
            groupStatusView(ticketVM: ticketVM)
            
            Divider()
                .padding(.horizontal, 20)
            
            Text("Most Popular Bets")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
            MostPopularBetsView(bookVM: bookVM)
                

        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear() {
            authenticationVM.fetchUser()
            ticketVM.fetchUserGroups() {}
            bookVM.fetchMostPopularBets()
        }
    }
}

struct ProfileHeaderView: View {
    @StateObject var authVM: authenticationViewModel
    var body: some View {
        ZStack {
            Color.blue
                .frame(height: 100)
                .cornerRadius(20)
                .shadow(radius: 10)
            
            Text("\(authVM.currUser?.username ?? "")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct groupStatusView: View {
    @StateObject var ticketVM: ticketViewModel

    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: .init(), count: 4), spacing: 20) {
                // Adding headers
                Text("Group").font(.headline)
                Text("Total Won").font(.headline)
                Text("Total Potential").font(.headline)
                Text("Rank").font(.headline)
                
                // Populating the grid with data
                ForEach(0..<ticketVM.userGroups.count, id: \.self) { index in
                    Text(ticketVM.userGroups[index].groupName)
                    Text(String(ticketVM.userGroups[index].totalWon))
                    Text(String(ticketVM.userGroups[index].totalPotentialWon))
                    Text("#1")
                }
            }
            .padding() // For adding padding around the grid
            .onAppear() {
                ticketVM.fetchUserGroups {
                    print("were fetched")
                }
            }
        }
    }
}

struct MostPopularBetsView: View {
    @StateObject var bookVM: bookViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Removed the "Most Popular Bets" title
            
            ForEach(0..<bookVM.mostPopularBets.count, id: \.self) { index in
                HStack {
                    PopularBetView(index: index, bookVM: bookVM)
                }
            }
        }
        .padding(.horizontal, 20) // Add this line
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}



struct PopularBetView: View {
    var index: Int
    @StateObject var bookVM: bookViewModel
    private var extra: String {
        if bookVM.mostPopularBets[index].betType == .over {
            return "o"
        } else if bookVM.mostPopularBets[index].betType == .under {
            return "u"
        } else {
            if bookVM.mostPopularBets[index].betLine >= 0 {
                return "+"
            }
        }
        return ""
    }

    var body: some View {
        HStack {
            Text("\(index + 1). \(bookVM.mostPopularBets[index].teamName)").frame(width: 275, alignment: .leading)
            Spacer()
            Text("\(extra)\(bookVM.mostPopularBets[index].betLine)").frame(width: 60, alignment: .trailing)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
