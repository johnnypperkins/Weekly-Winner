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
                
                YourBetsView()
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        ZStack {
            Color.blue
                .frame(height: 200)
                .cornerRadius(20)
                .shadow(radius: 10)
            
            VStack(spacing: 10) {
                Image("profile_image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                
                Text("John Doe")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("UI/UX Designer")
                    .font(.subheadline)
                    .foregroundColor(.white)
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
