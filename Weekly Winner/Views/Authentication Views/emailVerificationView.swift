//
//  emailVerificationView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 2/19/24.
//

import SwiftUI

struct emailVerificationView: View {
    @ObservedObject var viewModel: authenticationViewModel
    @Binding var verified: Bool
    
    
    var body: some View {
        
        VStack{
            Spacer()
            Image("mailOpen")
                .resizable()
                .frame(width: 150,height: 150)
            
            Text("Confirm your email address")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 24))
                .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                .padding(.top,30)
            
            Text("We sent a confirmation email to:")
                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                .foregroundStyle(.white)
                .padding(.top,15)
            
            Text("Reid@gmail.com")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundStyle(.white)
                .padding(.top,8)
            
            Text("Check your email and click on the")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundStyle(.white)
                .padding(.top,8)
            
            Text("confirmation link to continue")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundStyle(.white)
                .padding(.top,0)
            
            Spacer()
            Button {
                viewModel.checkVerification { success in
                    verified = success
                }
            } label: {
                HStack{
                    Spacer()
                    
                    Text("Confirmed")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    //shadow
                    
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.horizontal,16)
                    .padding(.bottom,30)
            }

            
            
            
        }.navigationBarBackButtonHidden(true)
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .ignoresSafeArea()
        
    }
}

//#Preview {
//    emailVerificationView(viewModel: authenticationViewModel(), verified: <#Binding<Bool>#>)
//}
