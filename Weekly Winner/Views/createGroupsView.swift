//
//  createGroupsView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/15/23.
//

import SwiftUI
import Kingfisher

struct createGroupsView: View {
    @State private var groupName: String = ""
    @State private var groupImageURL: String = ""
    @State private var groupSlogan: String = ""
    @State private var isPrivate: Bool = false
    @State private var password: String = ""
    @State private var takenTextShown: Bool = false
    @StateObject private var viewModel = createGroupsViewModel()
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    
    @State private var oneLegNum: Int = 0
    @State private var twoLegNum: Int = 0
    @State private var threeLegNum: Int = 0
    @State private var fourLegNum: Int = 0
    @State private var fiveLegNum: Int = 0
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack{
                ScrollView {
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
                        else {
                            ZStack{
                                Circle()
                                    .frame(width: 100, height: 100)
                                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .onTapGesture {
                                        showImagePicker.toggle()
                                    }
                            }.clipShape(Circle())
                        }
                    }
                    .sheet(isPresented: $showImagePicker,
                            onDismiss: loadImage) {
                        imagePicker(image: $selectedImage)
                    }.padding([.top, .bottom])
                           
                    
                    VStack(alignment: .leading, spacing: 10) {
                      Text("Group Name")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                      HStack() {
                          TextField("Group Name", text: $groupName)
                          .foregroundColor(.white)
                          .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                          .background(Color(red: 0.13, green: 0.14, blue: 0.34))

                      }
                      .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                      .cornerRadius(10)
                      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    
                    VStack(alignment: .leading, spacing: 10) {
                      Text("Group Slogan")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                      HStack() {
                          TextField("Group Slogan", text: $groupSlogan)
                          .foregroundColor(.white)
                          .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                          .background(Color(red: 0.13, green: 0.14, blue: 0.34))

                      }
                      .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                      .cornerRadius(10)
                      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    
                    HStack{
                        Text("Private Group")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                            .foregroundColor(.white)
                        
                        Spacer()

                        Toggle(isOn: $isPrivate) {
                            
                        }
                    }.padding(.vertical,16)
                    if isPrivate {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Password")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                            HStack() {
                                TextField("Password", text: $password)
                                    .foregroundColor(.white)
                                    .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                            .cornerRadius(10)
                            .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    }
                    VStack {
                        CustomStepper(value: $oneLegNum, range: 0...8, title: "1 Legs")
                        CustomStepper(value: $twoLegNum, range: 0...5, title: "2 Legs")
                        CustomStepper(value: $threeLegNum, range: 0...4, title: "3 Legs")
                        CustomStepper(value: $fourLegNum, range: 0...3, title: "4 Legs")
                        CustomStepper(value: $fiveLegNum, range: 0...2, title: "5 Legs")
                    }
                    VStack {
                        Spacer()
                        Button {
                            viewModel.checkIfGroupNameTaken(groupName) { isTaken in
                                if isTaken {
                                    takenTextShown = true
                                } else {
                                    viewModel.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: customizeTicketFormat(oneLegNum,twoLegNum,threeLegNum,fourLegNum,fiveLegNum))
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack{
                                Spacer()
                                Text("Create")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                                .background(Color(red: 0.31, green: 0.57, blue: 1))
                                .cornerRadius(10)
                                .padding(.horizontal,16)
                                .padding(.bottom,100)
                        }
                    }.frame(minHeight: 0, maxHeight: .infinity)
                }
            }
            .padding(.horizontal,16)
//                .navigationBarTitle("Create Group", displayMode: .inline)
//                .foregroundColor(.white)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }
    }
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
}

func customizeTicketFormat(_ a: Int,_ b: Int,_ c: Int,_ d: Int,_ e: Int) -> [Int] {
    var ticketFormatArr: [Int] = []
    for _ in 0..<a {
        ticketFormatArr.append(1)
    }
    for _ in 0..<b {
        ticketFormatArr.append(2)
    }
    for _ in 0..<c {
        ticketFormatArr.append(3)
    }
    for _ in 0..<d {
        ticketFormatArr.append(4)
    }
    for _ in 0..<e {
        ticketFormatArr.append(5)
    }
    return ticketFormatArr
}

struct CustomStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let title: String
    
    var body: some View {
        HStack {
            Text("\(title): \(value)")
                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                if value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(5)
            }
          
            Button(action: {
                if value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .cornerRadius(5)
            }
        }.padding(.vertical, 5)

    }
}


struct createGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        createGroupsView()
    }
}
