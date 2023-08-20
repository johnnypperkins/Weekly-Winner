//
//  profilePhotoSelectorView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 8/16/23.
//


import SwiftUI

struct profilePhotoSelectorView: View {
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @ObservedObject var viewModel: authenticationViewModel
    @State private var collegeName: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    init(model: authenticationViewModel) {
        viewModel = model
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                
                Text("Profile Photo!")
                    .font(Font.custom(K.customFonts.lexendDecaSB, size: 24).weight(.semibold))
                      .foregroundColor(.white)
                    .padding(.top)
                VStack(alignment: .center){
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                    }
                    else {
                        Image(systemName: "photo.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .onTapGesture {
                                showImagePicker.toggle()
                            }
                    }
                }.padding()
                .sheet(isPresented: $showImagePicker,
                        onDismiss: loadImage) {
                    imagePicker(image: $selectedImage)
                 }
                       .padding(.top)
                       .padding(.bottom)
                
                Spacer()
                
                if let selectedImage = selectedImage  {
                    NavigationLink(destination: {
                        TermsAndConditionsView(viewModel: viewModel) },label: {
                            HStack{
                                Spacer()
                                
                                Text("Continue")
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
                    .simultaneousGesture(TapGesture().onEnded{
                        viewModel.uploadProfileImage(selectedImage)
                        Task{
                            await wait()
                        }
                    })
                }
                
                Spacer()
                
            }.navigationBarBackButtonHidden(true)
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else {return}
        profileImage = Image(uiImage: selectedImage)
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 4_000_000_000)
            print("Done")
        }
        catch { }
    }
}
