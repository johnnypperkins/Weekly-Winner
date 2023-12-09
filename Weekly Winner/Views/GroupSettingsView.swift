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
    let ticketFormat: [Int]
    let timeFrame: String

    @State private var oneLegNum: Int
    @State private var twoLegNum: Int
    @State private var threeLegNum: Int
    @State private var fourLegNum: Int
    @State private var fiveLegNum: Int
    @State private var showingAlert2 = false
    
    init(selectedGroup: Binding<Int>, viewModel: groupsViewModel, groupAdmin: String, groupNum: Int, ticketFormat: [Int], timeFrame: String) {
            self._selectedGroup = selectedGroup
            self.viewModel = viewModel
            self.groupAdmin = groupAdmin
            self.groupNum = groupNum
            self.ticketFormat = ticketFormat
            self.timeFrame = timeFrame

            self._oneLegNum = State(initialValue: ticketFormat.filter { $0 == 1 }.count)
            self._twoLegNum = State(initialValue: ticketFormat.filter { $0 == 2 }.count)
            self._threeLegNum = State(initialValue: ticketFormat.filter { $0 == 3 }.count)
            self._fourLegNum = State(initialValue: ticketFormat.filter { $0 == 4 }.count)
            self._fiveLegNum = State(initialValue: ticketFormat.filter { $0 == 5 }.count)
        }
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @State private var updateEnabled = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    VStack {
                        
                        if groupAdmin == Auth.auth().currentUser?.uid {
//                            Text("Edit Format") // will add design later obv
//                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
//                                .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
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
                                    ZStack {
                                        KFImage(URL(string: viewModel.userGroups[selectedGroup-1].groupImageURL))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                showImagePicker.toggle()
                                            }
                                        Text("Edit")
                                            .font(.custom(K.customFonts.lexendDecaLight, size: 12))
                                            .padding(5) // Add some padding around the text
                                            .background(K.veryLightGray)
                                            .cornerRadius(5)
                                            .foregroundColor(.black) // Set the text color if needed
                                            .opacity(0.66)
                                    }
                                }
                                Button(action: {
                                    if selectedImage != nil {
                                        viewModel.uploadGroupImage(selectedImage!, group: viewModel.userGroups[selectedGroup-1]) { a in
                                            viewModel.userGroups[selectedGroup-1].groupImageURL = a
                                        }
                                    }
                                    dismiss()
                                }) {
                                    Text("Update Photo")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                        .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                }.padding(.horizontal)
                            }
                        .sheet(isPresented: $showImagePicker,
                                onDismiss: loadImage) {
                            imagePicker(image: $selectedImage)
                         }
                               .padding(.top, 20)
                               .padding(.bottom)
                            VStack(spacing: 0) {
                                CustomStepper(value: $oneLegNum, range: 0...8, title: "1 Legs")
                                CustomStepper(value: $twoLegNum, range: 0...5, title: "2 Legs")
                                CustomStepper(value: $threeLegNum, range: 0...4, title: "3 Legs")
                                CustomStepper(value: $fourLegNum, range: 0...3, title: "4 Legs")
                                CustomStepper(value: $fiveLegNum, range: 0...2, title: "5 Legs")
                            }.padding(.horizontal)
                            if customizeTicketFormat(oneLegNum,twoLegNum,threeLegNum,fourLegNum,fiveLegNum) != ticketFormat {
                                Button(action: {
                                    viewModel.resetTicketFormat(newTicketFormat: customizeTicketFormat(oneLegNum,twoLegNum,threeLegNum,fourLegNum,fiveLegNum), groupID: viewModel.userTickets[selectedGroup-1].groupID, timeFrame: timeFrame) {
                                        
                                    }
                                    if selectedImage != nil {
                                        viewModel.uploadGroupImage(selectedImage!, group: viewModel.userGroups[selectedGroup-1]) { a in
                                            viewModel.userGroups[selectedGroup-1].groupImageURL = a
                                        }
                                    }
                                    dismiss()
                                }) {
                                    Text("Update Ticket")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                        .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                }.padding(.horizontal)
                            } else {
                                Text("Update").opacity(0.6)
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                            }
                        }
                        
                        
                        Spacer()
                        HStack {
                            Button(action: {
                                
                                
                                self.showingAlert2 = true
                                if showingAlert2 == true {
                                    AppUtility.shared.showCustomAlert(alertType: .none, message: "Are you sure you want to leave?", actionButtonTitle: K.appButtonTitle.leaveGroup, cancelButtonTitle: K.appButtonTitle.cancel) { action in
                                        if action == AlertButtonAction.okButton{
                                            selectedGroup -= 1
//                                            viewModel.leaveGroup(ticket: viewModel.userTickets[selectedGroup]) {
//                                                //selectedGroup = 1
//                                            }
                                            dismiss()
                                        }
                                        
                                    }
                                }
                            }) {
                                Text("Leave Group") // will add design later obv
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(K.finalColor.deleteRed)
                            }.padding()
                            
                        }
                        .background(K.finalColor.cardBlue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        
                        
                    }.padding(.bottom, 20)
                    
                }
            }.background(K.finalColor.backgroundBlue.ignoresSafeArea(.all))
        }
    }
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
}
