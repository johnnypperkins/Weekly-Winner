//
//  screen5.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Kingfisher

struct profileView: View {
    
    @ObservedObject var viewModel: profileViewModel
    @ObservedObject var viewModel2 = authenticationViewModel()
    @State var scrollViewOffset: CGFloat = 0
    //@State private var isShowingEditProfile: Bool = false
    @State private var isProfileEditing = false
    @Environment(\.dismiss) private var dismiss
     private var user: User

    
    init(user: User) {
        viewModel = profileViewModel(user: user)
        self.user = user
        
        if viewModel.user.isCurrentUser == false{
            
        }
    }
    
    var body: some View {
        VStack{
            NavigationStack{
                VStack{
                    if user.isCurrentUser == false {
                        HStack {
                            Button {
                                // 2
                                dismiss()
                                
                            } label: {
                                HStack {
                                    Image(systemName: "arrowshape.backward.fill")
                                        .resizable()
                                        .foregroundColor(.black)
                                        .padding(.leading)
                                        .frame(width: 40,height: 17)
                                }
                            }
                            Spacer()
                            
                            Button {
                                AppUtility.shared.showCustomAlert(alertType: .none, message: "Are you sure you want to block \(user.firstName)?", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: K.appButtonTitle.cancel) { action in
                                    if action == AlertButtonAction.okButton{
                                        viewModel.block()
                                    }
                                }
                            } label: {
                                HStack{
                                    Text("Block")
                                        .foregroundColor(K.darkBlue)
                                    Image(systemName: "flag")
                                        .foregroundColor(K.darkBlue)
                            }

                                
                            }
                        }.padding()
                    }
                    ScrollViewReader { proxyReader in
                        ScrollView {
                            //if let user = authInfo.currUser {
                            
                            Text(viewModel.user.firstName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom,0.5)
                            Text(viewModel.user.lastName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom,0.5)
                            
//                            NavigationLink(destination: authenticationView()) {
//                                Button(action: {
//                                    viewModel2.signOut()
//                                }) {
//                                    Text("Sign out")
//                                }
//                            }


                            KFImage(URL(string: viewModel.user.profileImageUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200,height: 200)
                                .cornerRadius(25)
                                .padding(.top,25)
                            
                            if user.isCurrentUser == true {
                                NavigationLink {
                                    editProfileView(user1: viewModel.user, profileVM: viewModel)
                                } label: {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .padding(.horizontal)
                                        .background(Color(.blue)
                                            .clipShape(Capsule())
                                                    //shadow
                                            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5))
                                }.id(UUID())
                                
                            }
                            else {
                                Button(action: {
                                    
                                    
                                     if viewModel.isBlocked {
                                        viewModel.unblock()
                                    }
                                    else  {
                                       
                                    }
                                    
                                    
                                }, label: {
                                    
                                
                                    if viewModel.isBlocked {
                                        Text("Unblock")
                                            .foregroundColor(.blue)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .padding(.horizontal)
                                            .background(Color(.blue)
                                                .clipShape(Capsule())
                                                        //shadow
                                                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5))
                                    }
                                    else  {
                                        Text("Unavailable")
                                            .foregroundColor(K.backgroundBlue)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .padding(.horizontal)
                                            .background(Color(.blue)
                                                .clipShape(Capsule())
                                                        //shadow
                                                .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5))
                                    }
                                    
                                })
                            }
                            //.sheet(isPresented: $isShowingEditProfile) {
                            // editProfileView()
                            //}
                            
//                            Text("Friends")
//                                .font(.title)
//                                .fontWeight(.semibold)
//
//                            NavigationLink(destination: {friendsList(user: viewModel.user)}, label: {
//                                Text("\(viewModel.followerCount)")
//                                    .foregroundColor(Color("Color 3"))
//                            }).id(UUID())
                            VStack{
                                
                                Divider()
                                
                                Text("Recent Comments")
                                    .bold()
                                    .padding()
                                
                            }
//                            VStack{
//                                ForEach(viewModel.comments) { comment in
//                                    selfCommentView(comment: comment)
//                                        //.padding(.top)
//
//                                }
//                            }
                        }
                    }
                }.navigationBarBackButtonHidden()
            }
       }.onAppear {
//           viewModel.startListening()
//           Task{
//               await viewModel.getCountOfStringsInArrayField(user1: user)
//           }
           
           
       }.navigationBarBackButtonHidden()
//        .onDisappear {
//           viewModel.stopListening()
//       }
    }
    
    }
struct SideMenuButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2) // Make the button text bigger
            .foregroundColor(.white)
            .padding(.bottom) // Add padding to create space between buttons
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

struct RulesView: View {
    var body: some View {
        VStack {
            Text("Rules Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Rules", displayMode: .inline)
    }
}
struct ContactView: View {
    var body: some View {
        VStack {
            Text("Contact Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Contact", displayMode: .inline)
    }
}

//struct Screen5_Previews: PreviewProvider {
//    static var previews: some View {
//        profileView(user: <#T##User#>)
//    }
//}
