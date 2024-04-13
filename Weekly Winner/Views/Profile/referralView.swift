//
//  referralView.swift
//  Weekly Winner
//
//  Created by Reid Brown on 4/13/24.
//

import Foundation
import SwiftUI

struct referralView: View {
    @StateObject var viewModel = ReferralViewModel()
    var body: some View {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                

                VStack {
                    K.finalColor.backgroundBlue
                    VStack (spacing: 5) {
                        Text("How To Invite Friends?")
                            .lexMedCustom(20, color: K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("     WagerPool users can earn 2 PoolBucks for every user they refer. To refer a friend, all they have to do is enter your promo code during sign up. Easy as that!")
                            .lexMedCustom(15, color: .white)
                            .padding(.bottom)
                        
                        Text("Promo code: \(StaticUserData.shared.username)")
                            .lexMedCustom(15, color: .white)
                            .padding(.bottom)
                        
                    }.padding(.horizontal)
                    
                    ReferralProgressBar(count: viewModel.referredUsers.count)
                        .frame(height: 30)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack (spacing: 5){
                            ForEach(viewModel.referredUsers, id: \.id) { user in
                                userBioReusable(user: user)
                            }
                        }
                    }
                }
            .onAppear() {
                viewModel.fetchUsersWithPromoCode() {_ in }
            }
        }
    }
}


struct userBioReusable: View {
    let user: User
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                HStack {
                    HStack(spacing: 11) {
                        HStack(spacing: 0) {
                            HStack(spacing: 5) {
                                profilePicDisplayView(dimension: 24, picURL: user.profileImageUrl)
                                HStack(spacing: 0){
                                    Text("\(user.username) ")
                                        .lexMedCustom(12, color: K.finalColor.titleBlue)
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .frame(height: 24)
                        
                        Spacer()
                        
                    }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                }
            }
            .padding(.vertical, 10)
            .frame(width: 345, height: 44)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
        }
    }
}


struct ReferralProgressBar: View {
    var count: Int
    private let totalSections = 5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Rectangle()
                    .frame(width: min(CGFloat(self.count % totalSections) / CGFloat(totalSections) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(K.finalColor.winningGreen)
                    .animation(.linear, value: count)
            }
        }
        .cornerRadius(5)
    }
}
