//
//  authenticationView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/8/23.
//

import SwiftUI

struct authenticationView: View {
    @State private var isShowingSignup = false
    @EnvironmentObject var viewModel: authenticationViewModel
    
    var body: some View {
        VStack {
            if isShowingSignup {
                SignupView(isShowingSignup: $isShowingSignup)
            } else {
                LoginView(isShowingSignup: $isShowingSignup)
            }
        }.padding(.horizontal,16)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .environmentObject(viewModel)
        .ignoresSafeArea(.all)
    }
}

struct LoginView: View {
    @Binding var isShowingSignup: Bool
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: authenticationViewModel
    @State private var isShowingPasswordReset = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack{
                Text("FreeWager")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 32).weight(.semibold))
                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity)
  
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
              Text("Email")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
              HStack() {
                  TextField("Email", text: $viewModel.email)
                  .foregroundColor(.white)
                  .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                  .background(Color(red: 0.13, green: 0.14, blue: 0.34))

              }
              .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
              .background(Color(red: 0.13, green: 0.14, blue: 0.34))
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
              .cornerRadius(15)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
            
            VStack(alignment: .leading, spacing: 10) {
              Text("Password")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
              HStack() {
                  SecureField("Password", text: $viewModel.password)
                  .foregroundColor(.white)
                  .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                  .background(Color(red: 0.13, green: 0.14, blue: 0.34))

              }
              .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
              .cornerRadius(10)
              .background(Color(red: 0.13, green: 0.14, blue: 0.34))
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
            .padding(.top,10)
            
            HStack{
                Spacer(minLength: 0)
                
                Button {
                    isShowingPasswordReset.toggle()
                } label: {
                    Text("Forgot Password?")
                        .foregroundColor(Color.white.opacity(0.6))
                }

            }
            .padding(.horizontal)
            //.padding(.top,30)
        .sheet(isPresented: $isShowingPasswordReset){
            PasswordResetView(viewModel: viewModel)
        }
        
            
            Button(action: {
                viewModel.signIn()
                
            }) {
                HStack{
                    Spacer()
                    Text("Login")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                        .foregroundColor(.white)
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.horizontal,16)
                    .padding(.bottom,100)
                    
            }
            Spacer()
            
            
            HStack{
                Text("Don't have an account? ")
                    .foregroundColor(.white)
                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                
                Button(action: {
                    withAnimation {
                        isShowingSignup = true
                    }
                }) {
                    Text("Sign up")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                }.animation(.spring(), value: 3)
            }.padding(.bottom, 40)
        }
    }
}

struct SignupView: View {
    @Binding var isShowingSignup: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: authenticationViewModel
    
//    private func signUpWithEmailPassword() {
//        Task {
//            if await viewModel.signUpWithEmailPassword() == true {
//            }
//        }
//    }
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                .foregroundColor(.white)
                //.fontWeight(.bold)
            
            TextField("First Name", text: self.$viewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Last Name", text: self.$viewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Username", text: self.$viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: self.$viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: self.$viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Perform signup action
                Task{
                    await viewModel.signUp()
                }
            }) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            HStack{
                Button(action: {
                    withAnimation {
                        isShowingSignup = false
                    }
                    
                }) {
                    Text("Already have an account? Login")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }.animation(.spring(), value: 3)
            }
        }
    }
}


struct PasswordResetView: View {
  //  @Binding var isPresented: Bool
    @State private var email: String = ""
    //@Environment(\.dismiss) var dismiss
    @State private var showingAlert = true
    @ObservedObject var viewModel: authenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack{
            
            Image(systemName: "lock.shield.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding(.top,10)
            
            Text("Forgot Password?")
                .font(Font.custom(K.customFonts.lexendDecaSB, size: 24).weight(.semibold))
                .foregroundColor(.white)
                .padding(.top,10)

                
            Text("We can help you reset your password. Enter your email.")
                .font(Font.custom(K.customFonts.lexendDecaLight, size: 13).weight(.light))
              .foregroundColor(.white)
              .padding(.top,3)
                
            VStack(alignment: .leading, spacing: 10) {
              Text("Email")
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
              HStack() {
                  TextField("Email", text: $email)
                  .foregroundColor(.white)
                  .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                  .background(Color(red: 0.13, green: 0.14, blue: 0.34))

              }
              .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
              .background(Color(red: 0.13, green: 0.14, blue: 0.34))
              .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
              .cornerRadius(15)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
            .padding(.top,40)
            .padding(.horizontal,16)
                
            Spacer()
                Button(action: {
                    viewModel.forgotPassButton_Tapped(email: email) {
                        if viewModel.errorMessage == "" {
                            AppUtility.shared.showCustomAlert(alertType: .none, message: "A link has been sent to your email with instructions to reset your password", actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.ok) { action in
                            }
                        }
                        else {
                            AppUtility.shared.showCustomAlert(alertType: .none, message: viewModel.errorMessage!, actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.ok) { action in
                            }
                        }
                    }
                    
                    
                    
                }, label: {
                    HStack{
                        Spacer()
                        Text("Send")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(.white)
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                        .background(Color(red: 0.31, green: 0.57, blue: 1))
                        .cornerRadius(10)
                        .padding(.horizontal,16)
                        .padding(.bottom,100)
                })
                .disabled(email.isEmpty)
                
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct authenticationView_Previews: PreviewProvider {
    static var previews: some View {
        authenticationView()
    }
}
