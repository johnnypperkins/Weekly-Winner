//
//  createGroupsView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/15/23.
//

import SwiftUI

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
//                    else {
//                        KFImage(URL(string: viewModel.profileImgURL))
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
//                            .foregroundColor(.blue)
//                            .onTapGesture {
//                                showImagePicker.toggle()
//                            }
//                    }
                }
            .sheet(isPresented: $showImagePicker,
                    onDismiss: loadImage) {
                imagePicker(image: $selectedImage)
             }
                   .padding(.top)
                   .padding(.bottom)
            }
            Form {
                Section {
                    TextField("Group Name", text: $groupName)
                    TextField("Group Slogan", text: $groupSlogan)
                }
                
                Toggle(isOn: $isPrivate) {
                    Text("Private Group")
                }
                
                if isPrivate {
                    SecureField("Password", text: $password)
                }
                
                Button(action: {
                    viewModel.checkIfGroupNameTaken(groupName) { isTaken in
                        if isTaken {
                            takenTextShown = true
                        } else {
                            viewModel.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password, ticketFormat: [4,2,1,0,1])
                            dismiss()
                        }
                    }
                   
                }) {
                    Text("Create Group")
                }
                Text(takenTextShown ? "Name Taken" : "") // this is retarded format ik well fix it
            }
            .navigationBarTitle("Create Group", displayMode: .inline)
            
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
