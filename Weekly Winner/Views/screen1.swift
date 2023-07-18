//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct UserProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProfileHeaderView()
                .padding(.top, 20)
            
            Divider()
                .padding(.horizontal, 20)
            
            VStack(spacing: 20) {
                MostPopularBetsView()
                    .padding(.horizontal, 20)
                
            }
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct ProfileHeaderView: View {
    //@StateObject var authenticationVM = authenticationViewModel()
    @StateObject var ticketVM = ticketViewModel()
    
    var body: some View {
        VStack {
            Color.blue
                .frame(height: 200)
                .cornerRadius(20)
                .shadow(radius: 10)
            
            LazyVGrid(columns: Array(repeating: .init(), count: 3), spacing: 20) {
                // Adding headers
                Text("Group").font(.headline)
                Text("Total Won").font(.headline)
                Text("Total Potential").font(.headline)
                
                // Populating the grid with data
                ForEach(0..<ticketVM.userGroups.count, id: \.self) { index in
                    Text(ticketVM.userGroups[index].id ?? "default")
                    Text(String(ticketVM.userGroups[index].totalWon))
                    Text(String(ticketVM.userGroups[index].totalPotentialWon))
                }
            }
            .padding() // For adding padding around the grid
        }
        .onAppear() {
            ticketVM.fetchUserGroups {
                print("were fetched")
            }
        }
    }
    
}

struct MostPopularBetsView: View {
    @StateObject var bookVM = bookViewModel()
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Most Popular Bets")
                .font(.headline)
            
            ForEach(0..<bookVM.mostPopularBets.count, id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                    Text(bookVM.mostPopularBets[index].teamName)
                    Text(bookVM.mostPopularBets[index].betType.rawValue)
                }
                
            }

        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear() {
            bookVM.fetchMostPopularBets()
        }
    }
}


struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
