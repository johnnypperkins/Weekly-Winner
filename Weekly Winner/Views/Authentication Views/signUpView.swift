//
//  signUpView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 2/20/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import _AuthenticationServices_SwiftUI

private enum FocusableFieldSignup: Hashable {
    case firstName
    case lastName
    case username
    case instagram
    case email
    case confirmedEmail
    case password
    case confirmedPassword
    case promoCode
}

struct SignupView: View {
    @Binding var isShowingSignup: Bool
    @State private var navigateTowardsConfirmation = false
    @EnvironmentObject var viewModel: authenticationViewModel
    @FocusState private var focus: FocusableFieldSignup?
    @ObservedObject private var keyboardManager = KeyboardManager()
    
    @State var confirmedEmail: String = ""
    @State var confirmedPassword: String = ""
    

    var body: some View {
        VStack {
            HStack{
                Text("WagerPool")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 32).weight(.semibold))
                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.top,80)
                .padding(.bottom,10)
  
            
            Text("Create Account")
                .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                .foregroundColor(.white)
                //.fontWeight(.bold)
            
            ScrollView {
                ScrollViewReader { scrollProxy in
                    VStack{
                        VStack(alignment: .leading, spacing: 10) {
                            Text("First Name")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                TextField("First Name", text: $viewModel.firstName)
                                    .placeholder(when: viewModel.firstName
                                        .isEmpty, placeholder: {
                                            Text("First Name").foregroundColor(.gray)
                                        })
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .firstName)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = .lastName
                                        }
                                    }
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.firstName)
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Last Name")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                TextField("Last Name", text: $viewModel.lastName)
                                    .placeholder(when: viewModel.lastName
                                        .isEmpty, placeholder: {
                                            Text("Last Name").foregroundColor(.gray)
                                        })
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .lastName)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = .email
                                        }
                                    }
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.lastName)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                TextField("Email", text: $viewModel.email)
                                    .placeholder(when: viewModel.email
                                        .isEmpty, placeholder: {
                                            Text("Email").foregroundColor(.gray)
                                        })
                                    .onChange(of: viewModel.email) { email in
                                        viewModel.email = email.lowercased()
                                    }
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)

                                    .focused($focus, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = .confirmedEmail
                                        }
                                    }
                                   
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.email)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Confirm Email")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                TextField("Confirm Email", text: $confirmedEmail)
                                    .placeholder(when: confirmedEmail
                                        .isEmpty, placeholder: {
                                            Text("Use a real email. You will need to confirm it.").foregroundColor(.gray)
                                        })
                                    .onChange(of: confirmedEmail) { email in
                                        confirmedEmail = email.lowercased()
                                    }
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .confirmedEmail)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = .password
                                        }
                                    }
                                
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.confirmedEmail)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Password")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                SecureField("Password", text: $viewModel.password)
                                    .placeholder(when: viewModel.password
                                        .isEmpty, placeholder: {
                                            Text("Password").foregroundColor(.gray)
                                        })
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .password)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = .confirmedPassword
                                        }
                                    }
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.password)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Confirm Password")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                SecureField("Confirm Password", text: $confirmedPassword)
                                    .placeholder(when: confirmedPassword
                                        .isEmpty, placeholder: {
                                            Text("Confirm Password").foregroundColor(.gray)
                                        })
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .confirmedPassword)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        withAnimation {
                                            self.focus = nil
                                        }
                                    }
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                            .cornerRadius(15)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                        .id(FocusableFieldSignup.confirmedPassword)
 
                        
                    }
//                .padding(.bottom, keyboardManager.keyboardHeight)
                .padding(.bottom, focus == nil ? 0 : 600)
                .onChange(of: focus) { newFocus in
                    //                    if newFocus == .password {
                    withAnimation {
                        scrollProxy.scrollTo(newFocus, anchor: .top)
                    }
                    //                    }
                }
            }
            }
            
            ZStack{
                if viewModel.email != confirmedEmail {
                    Text("Emails not same")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(K.finalColor.deleteRed)
                        .cornerRadius(10)
                } else {
                    if viewModel.password != confirmedPassword || confirmedPassword == "" || viewModel.password == "" {
                        Text("Passwords not same")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(K.finalColor.deleteRed)
                            .cornerRadius(10)
                    } else {
                        Button(action: {
                            // Perform signup action
                            Task{
                                await viewModel.signUp() {
                                    if viewModel.authenticationState == .authenticated {
                                        navigateTowardsConfirmation = true
                                    }
                                }
                                
                                if viewModel.errorMessage != "" && viewModel.authenticationState == .unauthenticated {
                                    AppUtility.shared.showCustomAlert(alertType: .none, message: viewModel.errorMessage ?? "", actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.ok) { action in
                                        
                                    }
                                }
                            }
                            profilePhotoSelectorView(model: viewModel)
                                .background(K.finalColor.backgroundBlue)
                        }, label: {
                            if viewModel.authenticationState != .authenticating{
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.firstName != "" && viewModel.lastName != "" && viewModel.email != "" && viewModel.password != "" ? K.finalColor.winningGreen : K.finalColor.winningGreen.opacity(0.5))
                                    .cornerRadius(10)
                            }
                            else{
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.vertical,8)
                                    .frame(maxWidth: .infinity)
                            }
                        })
                    }
                }
         
                NavigationLink(destination: profilePhotoSelectorView(model: viewModel)
                    .background(K.finalColor.backgroundBlue), isActive: $navigateTowardsConfirmation) {}

            }
            Spacer()
            
            HStack{
                Text("Already have an account? ")
                    .foregroundColor(.white)
                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                
                Button(action: {
                    withAnimation {
                        isShowingSignup = false
                    }
                }) {
                    Text("Login")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                }.animation(.spring(), value: 3)
            }.padding(.bottom, 40)
        }.onTapGesture {
            // Resigning first responder when tapping anywhere outside the TextField
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
