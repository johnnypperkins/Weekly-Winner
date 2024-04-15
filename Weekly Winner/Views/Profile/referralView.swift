
import Foundation
import SwiftUI

struct referralView: View {
    @StateObject var viewModel = ReferralViewModel()
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
            
            VStack {
                VStack {
                    Text("Referral Page")
                        .lexMedCustom(20, color: K.finalColor.titleBlue)
                        .padding(.top)
                    
                    Text("For every 5 users you refer, you will receive 15 poolBucks! When signing up, the user must use your username as their promo code (all lowercase) and you will receive a referral.")
                        .lexMedCustom(15, color: .white)
                        .padding()
                    
                    HStack (spacing: 0){
                        Text("Your Promo Code: ")
                            .lexMedCustom(15, color: .white)
                            .padding(3)
                        Text("\(StaticUserData.shared.username)")
                            .lexMedCustom(15, color: .white)
                            .padding(3)
                            .background(K.finalColor.titleBlue)
                            .cornerRadius(5)
                    }.padding(.bottom)
                }.background(K.finalColor.cardBlue).cornerRadius(7.5).padding()
                
                ReferralProgressBar(count: viewModel.referredUsers.count)
                    .frame(height: 35)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack (spacing: 5){
                        Text("Past Referrals")
                            .lexMedCustom(15, color: .white)
                            .padding()
                        
                        ForEach(viewModel.referredUsers, id: \.id) { user in
                            userBioReusable(user: user)
                        }
                    }
                }.frame(height: 300)
                Spacer()
            }.onAppear() {
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
