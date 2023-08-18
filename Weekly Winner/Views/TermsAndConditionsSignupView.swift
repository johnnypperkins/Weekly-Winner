//
//  TermsAndConditionsSignupView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 8/16/23.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @State private var isChecked = false
    @State private var showNextPage = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Terms and Conditions")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 24).weight(.semibold))
                      .foregroundColor(.white)
                      .padding()
                
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
                // Checkbox and button section
                VStack {
                    Toggle(isOn: $isChecked) {
                        Text("I have read and accept the Terms and End-User License Agreement (EULA)")
                    }.toggleStyle(SwitchToggleStyle(tint: Color(red: 0.31, green: 0.57, blue: 1)))
                    .foregroundColor(.white)
                    .padding()
                    
                    NavigationLink(destination: {
                        if isChecked {
                            tabBarView()
                        }
                    }, label: {
                        HStack{
                            Spacer()
                            
                            Text("Welcome")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                                            //shadow
                            
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(Color(red: 0.31, green: 0.57, blue: 1))
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,30)
                    })
                    .padding()
                    .disabled(!isChecked)
                }
            }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }.navigationBarBackButtonHidden(true)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
