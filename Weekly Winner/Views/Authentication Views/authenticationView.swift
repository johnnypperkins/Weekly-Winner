//
//  authenticationView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 6/8/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import _AuthenticationServices_SwiftUI

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

private enum FocusableFieldLogin: Hashable {
  case email
  case password
}

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            keyboardHeight = keyboardSize.height
    }

    @objc func keyboardWillHide(notification: Notification) {
            keyboardHeight = 0
    }
}

struct LoginView: View {
    @Binding var isShowingSignup: Bool
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: authenticationViewModel
    @State private var isShowingPasswordReset = false
    @FocusState private var focus: FocusableFieldLogin?
    @ObservedObject private var keyboardManager = KeyboardManager()
    @State private var showWebpage = false

    
    var body: some View {
        ScrollView{
            ScrollViewReader { scrollProxy in
                Spacer(minLength: 150)
                VStack {
                    Spacer()
                    HStack{
                        Text("WagerPool")
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
                            TextField("", text: $viewModel.email)
                                .placeholder(when: viewModel.email.isEmpty, placeholder: {
                                    Text("Email").foregroundColor(.gray)
                                })
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                .accentColor(.white)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focus, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    withAnimation {
                                        self.focus = .password
                                    }
                                }
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .cornerRadius(15)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .id(FocusableFieldLogin.email)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Password")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            SecureField("Password", text: $viewModel.password)
                                .placeholder(when: viewModel.password.isEmpty, placeholder: {
                                    Text("Password").foregroundColor(.gray)
                                })
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                .accentColor(.white)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .focused($focus, equals: .password)
                                .submitLabel(.done)
                                .onSubmit {
                                    withAnimation {
                                        self.focus = nil
                                    }
                                }
                            
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .cornerRadius(15)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    .padding(.top,10)
                    .id(FocusableFieldLogin.password)
                    .onAppear() {
                        viewModel.forceUpdate () {
                            if viewModel.updateURL != ""{
                                AppUtility.shared.showCustomAlert(alertType: .none, message: "There is a new, necessary update. Sorry we know this is annoying...", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: nil) { action in
                                    if action == AlertButtonAction.okButton{
                                        showWebpage.toggle()
                                    }
                                    
                                }
                            }
                        }
                    }.sheet(isPresented: $showWebpage) {
                        SafariView(url: URL(string: viewModel.updateURL)!)
                    }
                   
                    
                    HStack{
                        Spacer(minLength: 0)
                        
                        Button {
                            isShowingPasswordReset.toggle()
                        } label: {
                            Text("Forgot Password?")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.light))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        
                    }
                    .padding(.horizontal)
                    //.padding(.top,30)
                    .sheet(isPresented: $isShowingPasswordReset){
                        PasswordResetView(viewModel: viewModel)
                            .presentationDetents([.fraction(0.65)])
                    }
                    
                    ZStack{
                        Button(action: {
                            Task{
                                await viewModel.signIn()
                                if viewModel.errorMessage != "" && viewModel.authenticationState == .unauthenticated {
                                    AppUtility.shared.showCustomAlert(alertType: .none, message: viewModel.errorMessage ?? "", actionButtonTitle: nil, cancelButtonTitle: K.appButtonTitle.cancel) { action in
                                        
                                    }
                                }
                            }
                          
                                
                            
                        }) {
                            HStack{
                                Spacer()
                                Text("Login")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 55 , maxHeight: 55)
                                .background(Color(red: 0.31, green: 0.57, blue: 1))
                                .cornerRadius(10)
                                .padding(.horizontal,16)
                            
                            
                        }
                        if viewModel.authenticationState == .authenticated && viewModel.currUser?.email != "" {
                            
                            
                            NavigationLink {
                                profilePhotoSelectorView(model: viewModel)
                                    .background(K.finalColor.backgroundBlue)

                            } label: {
                                
                                Text("Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 55 , maxHeight: 55)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                
                            }
                        }
                    }
                    VStack{
                        HStack {
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white)
                            
                            Text("Or")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 13))
                            
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(.white)
                        }.padding(.horizontal,16)
                        VStack{
                            Button {
                                Task{
                                    await viewModel.signInWithGoogle()
                                }
                            } label: {
                                Image("googleSignIn")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                            }.padding(.bottom,10)

                            SignInWithAppleButton { request in
                                viewModel.handleSignInWithAppleRequest(request)
                                print("khklhk")
                            } onCompletion: { result in
                                viewModel.handleSignInWithAppleCompletion(result)
                                print("pressed")
                            }.signInWithAppleButtonStyle(.whiteOutline)
                                .frame(maxWidth: 220, minHeight: 50)
                                .clipShape(RoundedRectangle(
                                    cornerRadius: 50
                                ))

                            
                        }.padding(.top,5)
                    }
                    .padding(.bottom,75)
                    .padding(.top,20)
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
//                .padding(.bottom, keyboardManager.keyboardHeight)
                .padding(.bottom, focus == nil ? 0 : 200)
                .onChange(of: focus) { newFocus in
//                    if newFocus == .password {
                        withAnimation {
                            scrollProxy.scrollTo(newFocus, anchor: .top)
                        }
//                    }
                }
                
            }
        }
//        .onTapGesture {
//                // Resigning first responder when tapping anywhere outside the TextField
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }
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

extension View {
    
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
    
    func customButtonStyle(
        foreground: Color = .black,
        background: Color = .white
    ) -> some View {
        self.buttonStyle(
            ExampleButtonStyle(
                foreground: foreground,
                background: background
            )
        )
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner2(radius: radius, corners: corners))
    }

}

private struct ExampleButtonStyle: ButtonStyle {
    let foreground: Color
    let background: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.45 : 1)
            .foregroundColor(configuration.isPressed ? foreground.opacity(0.55) : foreground)
            .background(configuration.isPressed ? background.opacity(0.55) : background)
    }
}

#if os(iOS)
struct RoundedCorner2: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private enum FocusableFieldSignup: Hashable {
    case firstName
    case lastName
    case username
    case instagram
    case email
    case password
    case promoCode
}

struct SignupView: View {
    @Binding var isShowingSignup: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var promoCode = ""
    @EnvironmentObject var viewModel: authenticationViewModel
    @FocusState private var focus: FocusableFieldSignup?
    @ObservedObject private var keyboardManager = KeyboardManager()
    
//    private func signUpWithEmailPassword() {
//        Task {
//            if await viewModel.signUpWithEmailPassword() == true {
//            }
//        }
//    }
    
    var body: some View {
        VStack {
            HStack{
                Text("WagerPool")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 32).weight(.semibold))
                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.top,80)
                .padding(.bottom,30)
  
            
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
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                                    .accentColor(.white)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .focused($focus, equals: .email)
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
                        .id(FocusableFieldSignup.email)
                        
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
                        .id(FocusableFieldSignup.password)
 
                        
                    }
//                .padding(.bottom, keyboardManager.keyboardHeight)
                .padding(.bottom, focus == nil ? 0 : 250)
                .onChange(of: focus) { newFocus in
                    //                    if newFocus == .password {
                    withAnimation {
                        scrollProxy.scrollTo(newFocus, anchor: .top)
                    }
                    //                    }
                }
            }
            }
            .onTapGesture {
                    // Resigning first responder when tapping anywhere outside the TextField
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            ZStack{
                Button(action: {
                    // Perform signup action
                    Task{
                        await viewModel.signUp()
                        
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
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    else{
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical,8)
                            .frame(maxWidth: .infinity)
                    }
                })
                if viewModel.authenticationState == .authenticated {
                    
                    
                    NavigationLink {
                        profilePhotoSelectorView(model: viewModel)
                            .background(K.finalColor.backgroundBlue)
                    } label: {
                        
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                        
                    }
                }
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
                        if viewModel.errorMessage == nil {
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
                
        }.padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}


struct authenticationView_Previews: PreviewProvider {
    static var previews: some View {
        authenticationView()
            .environmentObject(authenticationViewModel())
    }
}
#endif
