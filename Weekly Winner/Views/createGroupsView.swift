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
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack{
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
             }
                   .padding(.top)
                   .padding(.bottom)
                
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
                    Spacer()
                    Button {
                        viewModel.checkIfGroupNameTaken(groupName) { isTaken in
                            if isTaken {
                                takenTextShown = true
                            } else {
                                viewModel.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: [4,2,1,0,1])
                                dismiss()
                            }
                        }
                    } label: {
                        HStack{
                            Spacer()
                            
                            Text("Create")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                                            //shadow
                            
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(Color(red: 0.31, green: 0.57, blue: 1))
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,100)
                    }
                }.frame(minHeight: 0, maxHeight: .infinity)
                
            }.padding(.horizontal,16)
           
                .navigationBarTitle("Create Group", displayMode: .inline)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }
            
        
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
}

struct createGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        createGroupsView()
    }
}
