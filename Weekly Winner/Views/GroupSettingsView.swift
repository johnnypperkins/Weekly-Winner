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
import Kingfisher

struct groupSettingsView: View {
    @Binding var selectedGroup: Int
    let viewModel: groupsViewModel
    let groupAdmin: String
    let groupNum: Int
    
    
    @State private var oneLegNum: Int = 0
    @State private var twoLegNum: Int = 0
    @State private var threeLegNum: Int = 0
    @State private var fourLegNum: Int = 0
    @State private var fiveLegNum: Int = 0
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    VStack {
                        Text("Edit Format") // will add design later obv
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                            .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                        if groupAdmin == Auth.auth().currentUser?.uid {
                            VStack(alignment: .center) {
                                if let profileImage = profileImage {
                                    profileImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            showImagePicker.toggle()
                                        }
                                }
                                else if viewModel.userGroups[selectedGroup-1].groupImageURL == "" {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            showImagePicker.toggle()
                                        }
                                }
                                else {
                                    KFImage(URL(string: viewModel.userGroups[selectedGroup-1].groupImageURL))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            showImagePicker.toggle()
                                        }
                                }
                            }
                        .sheet(isPresented: $showImagePicker,
                                onDismiss: loadImage) {
                            imagePicker(image: $selectedImage)
                         }
                               .padding(.top)
                               .padding(.bottom)
                            
                            CustomStepper(value: $oneLegNum, range: 0...8, title: "1 Legs")
                            CustomStepper(value: $twoLegNum, range: 0...5, title: "2 Legs")
                            CustomStepper(value: $threeLegNum, range: 0...4, title: "3 Legs")
                            CustomStepper(value: $fourLegNum, range: 0...3, title: "4 Legs")
                            CustomStepper(value: $fiveLegNum, range: 0...2, title: "5 Legs")
                            
                            Button(action: {
                                viewModel.resetTicketFormat(newTicketFormat: customizeTicketFormat(oneLegNum,twoLegNum,threeLegNum,fourLegNum,fiveLegNum), groupID: viewModel.userTickets[selectedGroup-1].groupID) {
                                    
                                }
                                if selectedImage != nil {
                                    viewModel.uploadGroupImage(selectedImage!, group: viewModel.userGroups[selectedGroup-1]) { a in
                                        viewModel.userGroups[selectedGroup-1].groupImageURL = a
                                    }
                                }
                                dismiss()
                            }) {
                                Text("Update")
                            }.padding(.horizontal)
                        }
                        
                        
                        Spacer()
                        HStack {
                            Button(action: {
                                //selectedGroup -= 1
                                viewModel.leaveGroup(ticket: viewModel.userTickets[selectedGroup-1]) {
                                }
                                dismiss()
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
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
}
