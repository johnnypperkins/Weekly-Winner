//
//  screen5.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Kingfisher

struct profileView: View {
    @ObservedObject var viewModel: profileViewModel // For whatever reason this is causing infinite loop
   // @ObservedObject var viewModel2 = authenticationViewModel()
//    @StateObject var groupsVM = groupsViewModel()
//    @State var scrollViewOffset: CGFloat = 0
//    //@State private var isShowingEditProfile: Bool = false
//    @State private var isProfileEditing = false
//    @Environment(\.dismiss) private var dismiss
    private var user: User
//
//    @State private var showDropdown = false
//    @State private var selectedGroup = "global"
//    var onOptionSelected: ((_ option: Ticket) -> Void)?
//
    
    init(user: User) {
        print("here")
        viewModel = profileViewModel(user: user)
        self.user = user
        
        if viewModel.user.isCurrentUser == false{
            
        }
    }
    var body: some View {
        Text("hello")
    }
}

/*
struct profileView: View {
    
    @ObservedObject var viewModel: profileViewModel
    @ObservedObject var viewModel2 = authenticationViewModel()
    @StateObject var groupsVM = groupsViewModel()
    @State var scrollViewOffset: CGFloat = 0
    //@State private var isShowingEditProfile: Bool = false
    @State private var isProfileEditing = false
    @Environment(\.dismiss) private var dismiss
    private var user: User
    
    @State private var showDropdown = false
    @State private var selectedGroup = "global"
    var onOptionSelected: ((_ option: Ticket) -> Void)?
    
    
    init(user: User) {
        viewModel = profileViewModel(user: user)
        self.user = user
        
        if viewModel.user.isCurrentUser == false{
            
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
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
                                                .foregroundColor(.white)
                                            Image(systemName: "flag")
                                                .foregroundColor(.white)
                                        }
                                        
                                        
                                    }
                                }.padding()
                            }
                            else {
                                ZStack {
                                    Text("My Profile")
                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        
                                    }
                                }.padding(.top, 50) // has to be at least 50 so doesnt interfere with safe area
                            }
                            ProfileStatsView(viewModel: viewModel, user: user)
                                .padding(.vertical)
                                .padding(.horizontal,20.5)
                            ZStack {
                                VStack {
                                    HStack {
                                        Text("Group Stats")
                                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation {
                                                showDropdown.toggle()
                                            }
                                        }) {
                                            ZStack() {
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(width: 113, height: 40)
                                                    .background(Color(red: 0.13, green: 0.14, blue: 0.34))
                                                    .cornerRadius(6)
                                                
                                                HStack() {
                                                    Text(selectedGroup)
                                                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14)) // change this to your custom font
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    if showDropdown{
                                                        withAnimation(){
                                                            Image(systemName: "chevron.down")
                                                                .frame(width: 24, height: 24)
                                                        }
                                                    }
                                                    else {
                                                        withAnimation(){
                                                            Image(systemName: "chevron.up")
                                                                .frame(width: 24, height: 24)
                                                        }
                                                    }
                                                }.padding(.horizontal)
                                            }
                                            .frame(width: 113, height: 40)
                                            .cornerRadius(14)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(.horizontal)
                                    
                                    groupStats()
                                        .padding(.all,16)
                                }
                                
                                // Dropdown outside of VStack
                                if showDropdown {
                                    HStack{
                                        Spacer()
                                        
                                        Dropdown(options: groupsVM.userTickets, onOptionSelected: { option in
                                            withAnimation(){
                                                showDropdown = false
                                                selectedGroup = option.groupName
                                            }
                                            self.onOptionSelected?(option)
                                        })
                                        .frame(maxWidth: 113, alignment: .trailing)
                                        .padding(.top,30 /*desired dropdown menu position from the top*/)
                                        .padding(.trailing,16 /*desired dropdown menu position from the trailing edge*/)
                                    }.frame(minWidth: 0, maxWidth: .infinity)
                                }
                            }
                            
                        }
                        Spacer()
                    }.padding(.top)
                    
                }
                .frame(minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            }
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
        }
    }
    
}

struct groupStats: View {
  var body: some View {
      VStack() {
        HStack() {
          Text("Most Won")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
          Text("$200")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 13)
          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
          HStack() {
            Text("Least Won")
              .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
              .foregroundColor(.white)
              
              Spacer()
              
            Text("$30")
              .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
              .foregroundColor(.white)
          }
          .padding(.horizontal)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 13)

          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
        HStack() {
          Text("Average Won")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
          Text("$100")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }.padding(.horizontal)
              .padding(.vertical, 13)
        .frame(maxWidth: .infinity)
          Rectangle()
            .foregroundColor(.clear)
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
            .overlay(Rectangle()
            .stroke(.white, lineWidth: 0.4))
            .padding(.horizontal)
        HStack() {
          Text("Highest Ranking")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
            .foregroundColor(.white)
            
            Spacer()
            
          Text("#32")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
            .foregroundColor(.white)
        }.padding(.horizontal)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
      }
      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
      .cornerRadius(10)
  }
}

struct Dropdown: View {
    var options: [Ticket]
    var onOptionSelected: ((_ option: Ticket) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<self.options.count, id: \.self) { num in
                    if num != 0{
                        Divider()
                            .bold()
                    }
                    DropdownRow(option: options[num], onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(minHeight: CGFloat(options.count) * 40, maxHeight: CGFloat(options.count) * 40)
        .padding(.vertical, 5)
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
                
        )
    }
}

struct DropdownRow: View {
    var option: Ticket
    var onOptionSelected: ((_ option: Ticket) -> Void)?

    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.groupName)
                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                    .foregroundColor(Color.white)
                
                Spacer()
            }
        }.frame(height: 30)
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
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

struct ProfileStatsView: View {
    @StateObject var viewModel: profileViewModel
    var user: User
  var body: some View {
    VStack(spacing: 30) {
      VStack(spacing: 16) {
            KFImage(URL(string: viewModel.profileImageURLHolder))
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .foregroundColor(.clear)
                .frame(width: 78, height: 78)
              
          Text(user.username)
              .font(Font.custom(K.customFonts.lexendDecaSB, size: 18))
              .foregroundColor(.white)
          
          Text(user.firstName + " " + user.lastName)
              .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
              .foregroundColor(.white)
          
//        Text("Member Since : Aug 09, 2023")
//          .font(Font.custom("Lexend Deca", size: 14).weight(.light))
//          .foregroundColor(.white)
          
          if user.isCurrentUser == true {
              NavigationLink {
                  editProfileView(user1: viewModel.user, profileVM: viewModel)
              } label: {
                  Text("Edit profile")
                      .foregroundColor(.white)
                      .fontWeight(.bold)
                      .padding()
                      .background(K.finalColor.titleBlue)
                      .cornerRadius(10)
                                  //shadow
                      .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 5)
              }
              .id(UUID())
              
              
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
      }
      .frame(maxWidth: .infinity)
      HStack(alignment: .top, spacing: 6) {
        VStack(spacing: 5) {
          Text("$ 799")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
            .foregroundColor(.white)
          Text("Most Wons")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
            .foregroundColor(.white)
        }
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 35, height: 0)
          .overlay(
            Rectangle()
              .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
          )
          .rotationEffect(.degrees(-90))
        VStack(spacing: 5) {
          Text("$ 192")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
            .foregroundColor(.white)
          Text("Least Wons")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
            .foregroundColor(.white)
        }
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 35, height: 0)
          .overlay(
            Rectangle()
              .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
          )
          .rotationEffect(.degrees(-90))
        VStack(spacing: 5) {
          Text("$ 80")
                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
            .foregroundColor(.white)
          Text("Average Wons")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
            .foregroundColor(.white)
        }
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 35, height: 0)
          .overlay(
            Rectangle()
              .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
          )
          .rotationEffect(.degrees(-90))
        VStack(spacing: 5) {
          Text("#36")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
            .foregroundColor(.white)
          Text("Highest Rank")
            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
            .foregroundColor(.white)
        }
      }
      .padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10))
      .frame(maxWidth: .infinity)
      .background(Color(red: 0.13, green: 0.14, blue: 0.34))
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .inset(by: 0.50)
          .stroke(Color(red: 0.31, green: 0.30, blue: 0.43), lineWidth: 0.50)
      )
    }
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
*/
