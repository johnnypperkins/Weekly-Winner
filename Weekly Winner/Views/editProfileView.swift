//
//  editProfileView.swift
//  Merge
//
//  Created by Johnny Perkins on 4/14/23.
//

import SwiftUI
import Kingfisher

struct editProfileView: View {
    var user: User
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: editProfileViewModel
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @StateObject var viewModelAuth = authenticationViewModel()
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var instagramText: String = "@liluzivert"
    @ObservedObject var profileVM: profileViewModel
    
    init(user1: User, profileVM: profileViewModel) {
        user = user1
        self.profileVM = profileVM
        viewModel = editProfileViewModel(user: user)
    }
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue.ignoresSafeArea(.all)
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

                        else if viewModel.profileImgURL == "" {
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
                                KFImage(URL(string: viewModel.profileImgURL))
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
                    }
                    .sheet(isPresented: $showImagePicker,
                           onDismiss: loadImage) {
                        imagePicker(image: $selectedImage)
                    }
                           .padding(.top)
                           .padding(.bottom)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("First Name")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            TextField("First Name", text: $viewModel.firstname)
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .cornerRadius(15)
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Last Name")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            TextField("Last Name", text: $viewModel.lastname)
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instagram")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            TextField("Instagram", text: $instagramText)
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Username")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            Text("\(viewModel.username)")
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            Spacer()
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .cornerRadius(15)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        HStack() {
                            //Spacer()
                            Text("\(viewModel.email)")
                                .foregroundColor(.white)
                                .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                                .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                            Spacer()
                            
                        }
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                        .cornerRadius(15)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                    
                    
                    Spacer()
                    
                    Button(action: {
                        // Perform update profile logic here
                        print("Profile updated")
                        viewModel.updateUserInfo()
                        if selectedImage != nil {
                            viewModel.uploadProfileImage(selectedImage!) {url in
                                profileVM.profileImageURLHolder = url
                                
                            }
                            
                            
                        }
                        withAnimation {
                            dismiss()
                        }
                        
                    }) {
                        HStack{
                            Spacer()
                            
                            Text("Update")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20))
                                .foregroundColor(.white)
                            //shadow
                            
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 56 , maxHeight: 56)
                            .background(Color(red: 0.31, green: 0.57, blue: 1))
                            .cornerRadius(10)
                            .padding(.horizontal,16)
                            .padding(.bottom,30)
                        
                    }
                }.padding(.horizontal,16)
                    .padding(.top,90)
                    .scrollContentBackground(.hidden)
                    .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                    //.navigationTitle(Text("Edit Profile"))
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                // 2
                                dismiss()
                                
                            } label: {
                                HStack {
                                    Image(systemName: "arrowshape.backward.fill")
                                        .resizable()
                                        .foregroundColor(.blue)
                                        .padding(.leading)
                                        .frame(width: 40,height: 17)
                                }
                            }
                            
                        }
                    }
                    .background(Color(red: 0.02, green: 0.05, blue: 0.26))
//                    .onAppear {
//                        let appearance = UINavigationBarAppearance()
//                        appearance.configureWithTransparentBackground()
//                        appearance.titleTextAttributes = [
//                            .font: UIFont(name: K.customFonts.lexendDecaMedium, size: 14)!,
//                            .foregroundColor: UIColor.white
//                        ]
//                        UINavigationBar.appearance().standardAppearance = appearance
//                        UINavigationBar.appearance().compactAppearance = appearance
//                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//                    }
                    
                
            }
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .ignoresSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
    
}

/*struct editProfileView_Previews: PreviewProvider {
    static var previews: some View {
        editProfileView(user1: <#User#>)
    }
}
*/
