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
                
               // YourBetsView()
                 //   .padding(.horizontal, 20)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Most Popular Bets")
                .font(.headline)
            
            ForEach(1...5, id: \.self) { index in
                Text("Bet \(index)")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct YourBetsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Bets This Week")
                .font(.headline)
            
            ForEach(1...5, id: \.self) { index in
                Text("Your Bet \(index)")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
