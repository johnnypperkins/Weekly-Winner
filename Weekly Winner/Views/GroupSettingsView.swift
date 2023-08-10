//
//  groupSettingsView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/9/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct groupSettingsView: View {
    @Binding var selectedGroup: Int
    let viewModel: groupsViewModel
    let groupAdmin: String
    
    
    @State private var oneLegNum: Int = 0
    @State private var twoLegNum: Int = 0
    @State private var threeLegNum: Int = 0
    @State private var fourLegNum: Int = 0
    @State private var fiveLegNum: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    Button(action: {
                        selectedGroup -= 1
                        viewModel.leaveGroup(ticket: viewModel.userTickets[selectedGroup]) {
                        }
                    }) {
                        Text("Edit Format") // will add design later obv
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                            .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                    }.padding()
                    VStack {
                        if groupAdmin == Auth.auth().currentUser?.uid {
                            CustomStepper(value: $oneLegNum, range: 0...8, title: "1 Legs")
                            CustomStepper(value: $twoLegNum, range: 0...5, title: "2 Legs")
                            CustomStepper(value: $threeLegNum, range: 0...4, title: "3 Legs")
                            CustomStepper(value: $fourLegNum, range: 0...3, title: "4 Legs")
                            CustomStepper(value: $fiveLegNum, range: 0...2, title: "5 Legs")
                        }
                    }.padding(.horizontal)
                   
                    Spacer()
                    HStack {
                        Button(action: {
                            selectedGroup -= 1
                            viewModel.leaveGroup(ticket: viewModel.userTickets[selectedGroup]) {
                            }
                        }) {
                            Text("Leave Group") // will add design later obv
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                        }.padding()
                        
                    }
                    .background(K.finalColor.cardBlue)
                    .cornerRadius(10)
                    .padding()
                        
                    
                    
                }.padding(.bottom, 30)
                
            }
        }.background(K.finalColor.backgroundBlue.ignoresSafeArea(.all))
    }
}
