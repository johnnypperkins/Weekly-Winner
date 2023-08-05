//
//  settingsView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/27/23.
//

import SwiftUI
import Kingfisher
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
    
    var body: some View {
        if let user = authInfo.currUser{
            NavigationStack {
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
                            
                            NavigationLink(destination: {}) {
                                HStack{
                                    ZStack{
                                        Circle()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.13, green: 0.14, blue: 0.34))
                                            .cornerRadius(43)
                                        Image(systemName: "newspaper")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.white)
                                    }
                                    Text("Rules")
                                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 16))
                                        .foregroundColor(.white)
                                }.padding(.vertical,10)
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
                            }
                            
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
                            }
                            
                            Divider()
                            
                            NavigationLink(destination: {}) {
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
                            }
                            
                            Divider()
                            
                        }
                        
                        VStack (alignment: .leading){
                            Button(action: {
                                self.showingAlert = true
                                if showingAlert == true {
                                    AppUtility.shared.showCustomAlert(alertType: .none, message: "Are you sure you want to sign out", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: K.appButtonTitle.cancel) { action in
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
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal, 16)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
                .scrollContentBackground(.hidden)
                .background(Color.white.edgesIgnoringSafeArea(.all))
                Spacer()
                //Spacer()
            }
            
            .toolbar(.hidden)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .navigationBarBackButtonHidden()
            
        }
        
    }
}


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
                            .foregroundColor(Color(.black))
                            .padding(.leading)
                            .frame(width: 40,height: 17)
                    }
                }
                Spacer()
            }.padding()
            ScrollView{
                VStack{
                    
                    Text("End-User License Agreement (EULA) - Merge - SocialSips. Please read this End-User License Agreement carefully before using Merge - SocialSips (\"the App). By downloading, installing, or using the App, you agree to be bound by the terms and conditions of this Agreement.")
                        .padding()
                    
                    Text("Agreement to Terms and Conditions")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    Text("This Agreement constitutes a legal agreement between you and Merge - SocialSips. By using the App, you acknowledge that you have read, understood, and agree to be bound by this Agreement. If you do not agree to these terms, you should not use the App.")
                        .padding()
                    
                    Text("Description of the App")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    
                    Text("Merge - SocialSips is an app designed and targeted at students who are actively attending a university around the world. It facilitates connections, expansion, and the establishment of relationships among students from different schools. The App aims to create a unique and special network that goes beyond individual universities/locations, with the mission of broadening horizons and bringing together students who share a commonality.")
                        .padding()
                    
                    Text("Prohibited Content and User Conduct")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("Users of Merge - SocialSips are strictly prohibited from posting or engaging in any objectionable, offensive, or abusive content. Objectionable content includes, but is not limited to, content that is discriminatory, harassing, defamatory, pornographic, violent, or in violation of any applicable laws or regulations. Users must conduct themselves in a respectful and appropriate manner when using the App, treating others with courtesy and refraining from engaging in abusive behavior towards other users.")
                        .padding()
                    
                    Text("Consequences of Violations")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("Merge - SocialSips has a zero-tolerance policy for objectionable content or abusive user behavior. Violations of the prohibited content and user conduct mentioned in Section 3 may result in immediate termination of the User's access to the App without prior notice. Merge - SocialSips reserves the right to take appropriate legal action against any User who violates these terms.")
                        .padding()
                }.padding()
                // Privacy Policy section
                VStack {
                    Text("Intellectual Property Rights")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    // Your privacy policy content here
                    // Replace with your own text or views
                    
                    // For demonstration purposes, we'll use a simple Text view
                    Text("Merge - SocialSips retains all intellectual property rights associated with the App, including but not limited to copyrights, trademarks, and patents. Users may not copy, modify, distribute, or create derivative works based on the App without the prior written consent of Merge - SocialSips.")
                        .padding()
                    
                    Text("Disclaimer of Warranty and Limitation of Liability")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("The App is provided on an \("as-is") basis without any warranties or guarantees of any kind, either express or implied. Merge - SocialSips shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of the App.")
                        .padding()
                    
                    Text("Termination")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("Merge - SocialSips reserves the right to terminate this Agreement and the User's access to the App at any time, for any reason, without prior notice.")
                        .padding()
                    
                    Text("Governing Law")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("This Agreement shall be governed by and construed in accordance with the laws of the United States of America, without regard to its conflict of law principles.")
                        .padding()
                    Text("Severability")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.black)
                    Text("If any provision of this Agreement is found to be invalid or unenforceable, the remaining provisions shall remain in full force and effect.")
                        .padding()
                    
                }.padding()
                VStack{
                    Text("By using Merge - SocialSips, you acknowledge that you have read and understood this Agreement, and agree to comply with all of its terms and conditions.")
                        .bold()
                        .font(.title2)
                    .foregroundColor(.black)                }
                .padding()
            }.navigationBarBackButtonHidden(true)
        }
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
                                .foregroundColor(.black)                                .padding(.leading)
                                .frame(width: 40,height: 17)
                        }
                    }
                    Spacer()
                }
                Text("The Merge Mission")
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                ScrollView{
                    Text("Merge is an app designed and targeted at students who are actively attending a university around the world. It is used to connect students and allow them to expand, and establish connections and relationships with others from differing schools. It will result in the establishment of a unique and special network amongst students beyond just their university/location. Ultimately, our mission is to broaden horizons and bring together students all sharing one commonality. ")
                        .padding()
                }
            }
        }.navigationBarBackButtonHidden()
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
                                .foregroundColor(.black)                                .padding(.leading)
                                .frame(width: 40,height: 17)
                        }
                    }
                    Spacer()
                }.padding()
                Text("The Merge Mission")
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                ScrollView{
                    Text("Merge is an app designed and targeted at students who are actively attending a university around the world. It is used to connect students and allow them to expand, and establish connections and relationships with others from differing schools. It will result in the establishment of a unique and special network amongst students beyond just their university/location. Ultimately, our mission is to broaden horizons and bring together students all sharing one commonality. ")
                        .padding()
                }
            }
        }.navigationBarBackButtonHidden()
    }
}

