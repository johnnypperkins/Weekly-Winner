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
        }
        .environmentObject(viewModel)
        .padding()
        .ignoresSafeArea(.all)
    }
}

struct LoginView: View {
    @Binding var isShowingSignup: Bool
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: authenticationViewModel
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.signIn()
                
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
            }
            
            Button(action: {
                withAnimation {
                    isShowingSignup = true
                }
            }) {
                Text("Don't have an account? Sign up")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }.animation(.spring(), value: 3)
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
            Text("Signup")
                .font(.title)
                .fontWeight(.bold)
            
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
                Text("Sign up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Button(action: {
                withAnimation {
                    isShowingSignup = false
                }
                
            }) {
                Text("Already have an account? Log in")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }.animation(.spring(), value: 3)
        }
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
