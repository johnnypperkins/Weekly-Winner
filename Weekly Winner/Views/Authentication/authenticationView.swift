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
    @State private var signedInAndNavigates = false

    
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
                                .textInputAutocapitalization(.none)  // Consider changing this to .none if you always want lowercase
                                .focused($focus, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    withAnimation {
                                        self.focus = .password
                                    }
                                }.onChange(of: viewModel.email) { email in
                                    viewModel.email = email.lowercased()
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
                        SafariView(url: URL(string: "https://apps.apple.com/us/app/wagerpool/id6461645537")!)
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
                                await viewModel.signIn() {
                                    if viewModel.authenticationState == .authenticated && viewModel.currUser?.email != "" {
                                        signedInAndNavigates = true
                                    }
                                }
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
                            
                        NavigationLink(destination: tabBarView(selection: .dashboard), isActive: $signedInAndNavigates) {}

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
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                .foregroundColor(.blue)
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
        .onTapGesture {
            // Resigning first responder when tapping anywhere outside the TextField
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
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
