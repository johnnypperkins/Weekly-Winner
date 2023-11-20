//
//  profilePhotoSelectorView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 8/16/23.
//


import SwiftUI
import Firebase

struct profilePhotoSelectorView: View {
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var profileImage: Image?
    @ObservedObject var viewModel: authenticationViewModel
    @State private var collegeName: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State var selectedState = ""
    @State var age: Int?
    @State var country: String = ""
    @State private var selectedGender = "Male"
    
    let states = [
            "Choose here","Alabama", "Alaska", "Arizona", "Arkansas", "California",
            "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
            "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas",
            "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
            "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
            "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
            "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma",
            "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
            "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
            "West Virginia", "Wisconsin", "Wyoming"
        ]
    
    
    init(model: authenticationViewModel) {
        viewModel = model
    }
    
    var body: some View {
//        NavigationStack{
            VStack {
                
                Text("Complete Your Profile!")
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
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Country")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                    HStack() {
                        TextField("Country", text: $country)
                            
                            .placeholder(when: country
                                .isEmpty, placeholder: {
                                    Text("Country").foregroundColor(.gray)
                                })
                            .foregroundColor(.white)
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                            .accentColor(.white)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
//                                            .textCase(.lowercase)
//                            .focused($focus, equals: .username)
                            .submitLabel(.next)
                            .onSubmit {
//                                withAnimation {
//                                    self.focus = .instagram
//                                }
                            }
                        
                    }
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .cornerRadius(15)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                .padding(.horizontal,16)
//                .id(FocusableFieldSignup.username)
                
                HStack {
                    Text("State")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        
                    Text("(if residing in the USA):")
                        .font(Font.custom(K.customFonts.lexendDecaLight, size: 12).weight(.light))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                        .padding(.trailing,10)
                    
                    Spacer()
                            Picker("Select a state", selection: $selectedState) {
                                ForEach(states, id: \.self) { state in
                                    Text(state)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                       
                            
                        }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                .padding(.horizontal,16)
//                .id(FocusableFieldSignup.username)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Age")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                    HStack() {
                        TextField("Age", text: Binding(
                            get: { String(self.age ?? -99) },
                            set: { if let newValue = Int($0) { self.age = newValue } }
                        ))
                            
                            
                            .foregroundColor(.white)
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14))
                            .accentColor(.white)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
//                                            .textCase(.lowercase)
//                            .focused($focus, equals: .username)
                            .submitLabel(.next)
                            .onSubmit {
//                                withAnimation {
//                                    self.focus = .instagram
//                                }
                            }
                        
                    }
                    .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 15))
                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .cornerRadius(15)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
                .padding(.horizontal,16)
//                .id(FocusableFieldSignup.username)
                HStack{
                    Text("Select Your Sex:")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.88, green: 0.89, blue: 0.89))
                    
                    Spacer()
                    
                    Picker("Sex", selection: $selectedGender) {
                                   Text("Male").tag("Male")
                                   Text("Female").tag("Female")
                               }
                   
                }.padding(.horizontal,16)
                    .padding(.top,5)
                
                Spacer()
                
                if let selectedImage = selectedImage  {
                    if country != "" && String(age ?? -99) != "0" {
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
                        viewModel.uploadSupplementaryData(country: country, age: age ?? -99, state: selectedState, gender: selectedGender)
                        Task{
                            await wait()
                        }
                    })
                }
                }
                
                Spacer()
                
            }.navigationBarBackButtonHidden(true)
        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
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


