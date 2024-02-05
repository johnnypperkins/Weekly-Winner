//
//  settingsView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/27/23.
//

import SwiftUI
import Kingfisher
import SafariServices
//import SafariServices
//import CustomAlert

struct settingsView: View {
    @ObservedObject var authInfo = authenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var darkModeEnabled = false
    @State private var showWebpage = false
    @State private var showingAlert = false
    @State private var showingAlert2 = false
    @State private var showContentView = false
    @State private var showInvitePage = false
    
    var body: some View {
        if let user = authInfo.currUser{
            NavigationStack {
                ZStack {
                    K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                    ScrollView{
                        VStack(alignment: .leading) {
                            HStack {
                                Button {
                                    // 2
                                    dismiss()
                                    
                                } label: {
                                    HStack {
                                        Image(systemName: "arrowshape.backward.fill")
                                            .resizable()
                                            .foregroundColor(.white)
                                            .padding(.leading)
                                            .frame(width: 40,height: 17, alignment: .leading)
                                    }
                                }
                                Spacer()
                                
                                //Spacer(minLength: 1)
                                
                                Text("Settings")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                                    .foregroundColor(.white)
                                    .padding(.leading,7)
                                
                                Spacer()
                                
                                KFImage(URL(string: user.profileImageUrl))
                                    .resizable()
                                    .frame(width: 40,height: 40, alignment: .trailing)
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(20)
                                    .padding(.trailing)
                            }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,minHeight: 0, maxHeight: 80, alignment: .top
                            )
                            VStack(alignment:.leading) {
                                VStack(alignment: .leading){
                                    
                                    Text("About")
                                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 16).weight(.semibold))
                                        .foregroundColor(.white)
                                    NavigationLink(destination: {aboutUsView()}) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("About Us")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical, 10)
                                    }
                                    .id(UUID())
                                
                                    Divider()
                                    
                                    NavigationLink(destination: {ourMissionView()}) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Our Mission")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.top, 10)
                                            .padding(.bottom,20)
                                    }.id(UUID())
                                    
                                }
                                
                                VStack(alignment: .leading){
                                    
                                    Text("User")
                                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 16).weight(.semibold))
                                        .foregroundColor(.white)
                                    NavigationLink(destination: {editProfileView(user1: StaticUserData.shared.currentUser)}) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Edit Profile")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical, 10)
                                    }.id(UUID())
//                                    
//                                    Divider()
                                    
                                    Button(action: {
                                        showInvitePage.toggle()
                                    }) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Invite Friends")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.top, 10)
                                            .padding(.bottom,20)
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading) {
                                    //                            Button(action: {
                                    //                                self.showWebpage = true
                                    //                            }) {
                                    //                                Text("Open Website")
                                    //                                    .foregroundColor(Color("Color 1"))
                                    //                            }
                                    //                            .sheet(isPresented: $showWebpage) {
                                    //                                SafariView(url: URL(string: "https://merge-together.com")!)
                                    //                            }
                                    Text("Support")
                                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 16).weight(.semibold))
                                        .foregroundColor(.white)
                                    
                                    
                                    
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                .cornerRadius(43)
                                            Image(systemName: "newspaper")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                        }
                                        Text("How to play")
                                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 10)
                                                .onTapGesture {
                                                    if let url = URL(string: "https://www.youtube.com/watch?v=8lYjqQby3AI&t=16s") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                    
                                    
                                    Divider()
                                    
                                    NavigationLink(destination: {TermsAndConditionsViewSettings()}) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Terms and Conditions")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical,10)
                                    }.id(UUID())
                                    
                                    Divider()
                                    
                                    NavigationLink(destination: {TermsAndConditionsViewSettings()}) {
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "lock.shield.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Privacy Policy")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical,10)
                                    }.id(UUID())
                                    
                                    Divider()
                                    
                                    
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                Image(systemName: "phone.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Contact")
                                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical,10)
                                    .onTapGesture {
                                        if let url = URL(string: "https://forms.gle/kwyQbAGB4SRs7EVFA") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    
                                    //Divider()
                                    
                                }
                                
                                VStack (alignment: .leading){
                                    Button(action: {
                                        self.showingAlert = true
                                        if showingAlert == true {
                                            AppUtility.shared.showCustomAlert(alertType: .none, message: "Are you sure you want to sign out", actionButtonTitle: K.appButtonTitle.signOut, cancelButtonTitle: K.appButtonTitle.cancel) { action in
                                                if action == AlertButtonAction.okButton{
                                                    showContentView.toggle()
                                                    authInfo.signOut()
                                                }
                                                
                                            }
                                        }
                                    }) {
                                        
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                
                                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                            }
                                            Text("Sign Out")
                                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.white)
                                        }.padding(.vertical,10)
                                        
                                    }
                                    
                                    Divider()
                                    
                                    
                                    Button(action: {
                                        self.showingAlert2 = true
                                        if showingAlert2 == true {
                                            AppUtility.shared.showCustomAlert(alertType: .none, message: "Are you sure you want to delete your account? Once this is done, the account cannot be recovered.", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: K.appButtonTitle.cancel) { action in
                                                if action == AlertButtonAction.okButton{
                                                    showContentView.toggle()
                                                    Task{
                                                        await authInfo.deleteAccount()
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }) {
                                        
                                        
                                        HStack{
                                            ZStack{
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(43)
                                                
                                                Image(systemName: "trash.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.red)
                                            }
                                            Text("Delete Account")
                                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                                .foregroundColor(.red)
                                        }.padding(.vertical,10)
                                    }
                                }
                            }.frame(minWidth: 0, maxWidth: .infinity)
                                .navigationDestination(isPresented: $showContentView) {
                                    ContentView()
                                }
                            Spacer()
                            //Color.white.edgesIgnoringSafeArea(.all)
                        }.edgesIgnoringSafeArea(.bottom)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
                        .scrollContentBackground(.hidden)
                        .background(Color.white.edgesIgnoringSafeArea(.all))
                    }.edgesIgnoringSafeArea(.bottom)
                        .padding(.bottom,40)
                    Spacer()
                    //Spacer()
                }.popup(isPresented: $showInvitePage) {
                    inviteFriendsView()
                    .frame(height: 650)
                } customize: {
                    $0
                        .type (.toast)
                        .position(.bottom)
                        .isOpaque(true)
                        .closeOnTap(false)
                        .closeOnTapOutside(true)
                        .backgroundColor(.black.opacity(0.4))
                }
                .edgesIgnoringSafeArea(.bottom)
                
                .toolbar(.hidden)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .navigationBarBackButtonHidden()
                .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .edgesIgnoringSafeArea(.bottom)
        }
        
    }
}
struct YouTubeButtonContent: View {
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(43)
                Image(systemName: "newspaper")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            Text("How to play")
                .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        //.padding()
//        .background(Color.blue)
//        .cornerRadius(8)
    }
}

//NavigationLink(destination: {TermsAndConditionsViewSettings()}) {
//    HStack{
//        ZStack{
//            Circle()
//                .frame(width: 40, height: 40)
//                .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
//                .cornerRadius(43)
//            Image(systemName: "rectangle.and.pencil.and.ellipsis")
//                .resizable()
//                .frame(width: 20, height: 20)
//                .foregroundColor(.white)
//        }
//        Text("Terms and Conditions")
//            .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
//            .foregroundColor(.white)
//    }.padding(.vertical,10)
//}

//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//        // Update the view controller if needed
//    }
//}

struct settingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsView()
    }
}

struct inviteFriendsView: View {
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.cornerRadius(40, corners: [.topLeft, .topRight])
            VStack {
                
              popUpPill()
                
                ScrollView {
                    K.finalColor.backgroundBlue
                    VStack (spacing: 5) {
                        Text("How To Invite Friends?")
                            .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                            .foregroundColor(K.finalColor.titleBlue)
                            .padding(.vertical)
                        
                        Text("     WagerPool users can earn 2 PoolBucks for every user they refer. To refer a friend, all they have to do is enter your promo code during sign up. Easy as that!")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        Text("Promo code: \(StaticUserData.shared.username)")
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                            .foregroundColor(K.finalColor.textWhite)
                            .padding(.bottom)
                        
                        
                    }.padding(.horizontal)
                }
            }
        }
    }
}
struct TermsAndConditionsViewSettings: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            HStack {
                Button {
                    // 2
                    dismiss()
                    
                } label: {
                    HStack {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .foregroundColor(Color(.white))
                            .padding(.leading)
                            .frame(width: 40,height: 17)
                    }
                }
                Spacer()
            }.padding()
            ScrollView{
                VStack{
                    
                    Text("End-User License Agreement (EULA) WagerPool. Please read this End-User License Agreement carefully before using WagerPool (\"the App). By downloading, installing, or using the App, you agree to be bound by the terms and conditions of this Agreement.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Agreement to Terms and Conditions")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("This Agreement constitutes a legal agreement between you and WagerPool. By using the App, you acknowledge that you have read, understood, and agree to be bound by this Agreement. If you do not agree to these terms, you should not use the App.")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Description of the App")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("Welcome to WagerPool, the fantasy betting app designed to bring friendly competition and excitement to your fingertips. At WagerPool, we believe that having fun with friends shouldn't require real money wagers. Our app allows you to create weekly cards, place bets, and compete for bragging rights without any financial risk. Our goal is to create a safe and engaging environment where you can showcase your strategic skills, challenge your friends, and climb the global leaderboard. With the option to adjust risk and reward, you can tailor your betting strategy to your unique style. Remember, to conquer the group, you'll need to embrace just the right amount of risk.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Prohibited Content and User Conduct")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("Users of WagerPool are strictly prohibited from posting or engaging in any objectionable, offensive, or abusive content. Objectionable content includes, but is not limited to, content that is discriminatory, harassing, defamatory, pornographic, violent, or in violation of any applicable laws or regulations. Users must conduct themselves in a respectful and appropriate manner when using the App, treating others with courtesy and refraining from engaging in abusive behavior towards other users.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Consequences of Violations")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("WagerPool has a zero-tolerance policy for objectionable content or abusive user behavior. Violations of the prohibited content and user conduct mentioned in Section 3 may result in immediate termination of the User's access to the App without prior notice. WagerPool reserves the right to take appropriate legal action against any User who violates these terms.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                }
                // Privacy Policy section
                VStack {
                    Text("Intellectual Property Rights")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    // Your privacy policy content here
                    // Replace with your own text or views
                    
                    // For demonstration purposes, we'll use a simple Text view
                    Text("WagerPool retains all intellectual property rights associated with the App, including but not limited to copyrights, trademarks, and patents. Users may not copy, modify, distribute, or create derivative works based on the App without the prior written consent of WagerPool.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Disclaimer of Warranty and Limitation of Liability")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("The App is provided on an \("as-is") basis without any warranties or guarantees of any kind, either express or implied. WagerPool shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of the App.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                }
                VStack{
                    Text("Disclaimer of Betting Advice and Odds")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    Text("The Company provides the WagerPool mobile application \("App") for entertainment purposes only. The information, tips, and advice presented within the App regarding betting strategies, odds, and outcomes are not intended as professional betting advice. Users are solely responsible for making their own decisions when participating in the fantasy betting activities provided by the App.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("The Company does not endorse or recommend any particular betting strategy, and the information provided within the App should not be construed as a guarantee of successful outcomes. Betting involves risk, and the results of bets may vary based on unpredictable factors.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("By using the App, you acknowledge and agree that: Any betting decisions made based on information provided within the App are done at your own risk. The Company does not assume responsibility for the accuracy, reliability, or suitability of any information presented within the App. The Company is not liable for any losses, damages, or consequences arising from bets placed or decisions made based on information presented within the App.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Additionally, all betting odds presented within the App are generated for user-friendly and entertainment purposes. These odds are not accurate reflections of real-world betting odds and should not be relied upon for actual betting activities. The Company reserves the right to adjust or modify odds and outcomes within the App without prior notice. Before placing any bets or making decisions related to betting activities, we strongly recommend that you conduct your own research, consult with professionals, and consider your own judgment and risk tolerance.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Disclaimer of Betting Advice and Odds")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                        .padding()
                    Text("By participating in any contests or activities that award prizes through our app, you grant WagerPool the right to use your name, likeness, image, photograph, voice, biographical information, and any statements made by you on WagerPool for promotional purposes, including pictures, social media posts, advertisements, and other promotional materials. Your Likeness may be featured on the Company's platforms. Additionally, you consent to the Company's affiliate, WagerPool, using any data, picks, bets, predictions, and related information generated through your participation for promotional purposes. By participating, you waive rights to inspect or approve finished materials and release the Company and WagerPool from claims. This agreement is binding, and you acknowledge your consent for the use of your Likeness and data as described.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                }.padding()
                VStack{
                    Text("Termination")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    Text("WagerPool reserves the right to terminate this Agreement and the User's access to the App at any time, for any reason, without prior notice.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Governing Law")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("This Agreement shall be governed by and construed in accordance with the laws of the United States of America, without regard to its conflict of law principles.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Severability")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    
                    Text("If any provision of this Agreement is found to be invalid or unenforceable, the remaining provisions shall remain in full force and effect.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                }
                VStack{
                    Text("By using WagerPool, you acknowledge that you have read and understood this Agreement, and agree to comply with all of its terms and conditions.")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                        .foregroundColor(.white)
                    }
                .padding()
            }.navigationBarBackButtonHidden(true).background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}


struct ourMissionView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                HStack {
                    Button {
                        // 2
                        dismiss()
                        
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.backward.fill")
                                .resizable()
                                .foregroundColor(.white)                                .padding(.leading)
                                .frame(width: 40,height: 17)
                        }
                    }
                    Spacer()
                }
                Text("The WagerPool Mission")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 24))
                    .foregroundColor(.white)
                ScrollView{
                    Text("Welcome to WagerPool, the fantasy betting app designed to bring friendly competition and excitement to your fingertips. At WagerPool, we believe that having fun with friends shouldn't require real money wagers. Our app allows you to create weekly cards, place bets, and compete for bragging rights without any financial risk.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    Text("Our goal is to create a safe and engaging environment where you can showcase your strategic skills, challenge your friends, and climb the global leaderboard. With the option to adjust risk and reward, you can tailor your betting strategy to your unique style. Remember, to conquer the group, you'll need to embrace just the right amount of risk.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    Text("Thank you for choosing WagerPool. We're excited to have you on board, and we're dedicated to providing you with an enjoyable and fair fantasy betting experience.")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    Text("Follow us on Instagram to keep up with weekly winners and exciting bets!")
                        .padding(.bottom)
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18))
                        .foregroundColor(.white)
                    
                    
                    
                }.padding(.horizontal,16)
            }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }.navigationBarBackButtonHidden()
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

struct prizesView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Prizes")
        }
    }
}

struct aboutUsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                HStack {
                    Button {
                        // 2
                        dismiss()
                        
                    } label: {
                        HStack {
                            Image(systemName: "arrowshape.backward.fill")
                                .resizable()
                                .foregroundColor(.white)                                .padding(.leading)
                                .frame(width: 40,height: 17)
                        }
                    }
                    Spacer()
                }.padding()
                Text("About Us")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 24))
                    .foregroundColor(.white)
                    .padding(.bottom)
                Text("A Third Person Perspective: Turning an Idea into Reality")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 14))
                    .foregroundColor(.white)
                ScrollView{
                    Text("In the bustling atmosphere of Wake Forest University, two college students, Reid and Johnny, embarked on an extraordinary journey that would transform a simple idea into a tangible reality. Guided by their shared passion for technology, innovation, and a touch of friendly competition, they set out to create an experience that would forever change the way friends connect and compete. Thus began the inspiring tale of the WagerPool fantasy betting app.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12))
                        .foregroundColor(.white)
                    
                    Text("As the sun set, late nights blended seamlessly into early mornings, as Reid and Johnny fervently immersed themselves in the world of app development. Armed with laptops, fueled by endless cups of coffee, and guided by an unwavering optimism, they embarked on a challenge that would put their skills, creativity, and commitment to the ultimate test. The university library transformed into their sanctuary, where lines of code meticulously crafted filled their computer screens like pieces of a complex puzzle waiting to be assembled.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Reid's initial spark of an idea set this whole jounrey into motion. It was his innovative insight that ignited the project's flames. Reid envisioned blending the thrill of betting with the camaraderie of friendly competition, painting a picture of an experience that would transcend conventions. He shared his vision with Johnny, a partner whose boundless optimism would be the driving force behind the project's long-term success.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    
                    Text("While Johnny recognized the idea's immense potential, he was acutely aware of the hurdles that lay ahead. He understood that the journey would demand dedication and hard work. But it was Johnny's unyielding optimism that illuminated their path, a constant reminder that challenges were merely opportunities in disguise, and that dreams were achievable through determination and perseverance.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Between lectures, exams, and countless commitments, Reid and Johnny dedicated themselves wholeheartedly to their venture. They delved into comprehensive research, sought guidance from mentors, and engaged with potential users to fine-tune their vision. As lines of code transformed into a functional app, the duo's expertise grew, a testament to their determination to master the craft.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Months of unceasing effort, countless nights devoid of sleep, and unwavering commitment led to the emergence of WagerPool. The app was the embodiment of Reid's original inspiration and Johnny's enduring optimism. It was a platform that offered an experience that encapsulated their shared dream – a dream born from Reid's inventive thinking and nurtured by Johnny's perpetual belief in its potential.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("As college students turned creators, Reid and Johnny reflect on their journey with pride and satisfaction. Their narrative is a testament to the potency of innovation and the significance of steadfast commitment. With WagerPool now reaching users across the globe, their dream lives on, woven into every bet placed, every competition won, every brag delt, and every shared moment of exhilaration.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    Text("Navigating the ever-evolving landscape of technology and entrepreneurship, Reid and Johnny remain true to their initial vision: to craft an app that not only unites friends through competition and the thrill of betting but also stands as a testament to the remarkable power of shared dreams transformed into tangible reality.")
                        .padding()
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                        .foregroundColor(.white)
                    
                    
                }
            }
            
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }.navigationBarBackButtonHidden()
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

//
//func openYouTubeLink() {
//    if let url = URL(string: "https://www.youtube.com/watch?v=8lYjqQby3AI&t=16s") {
//        let safariVC = SFSafariViewController(url: url)
//        present(safariVC, animated: true, completion: nil)
//    }
//}
