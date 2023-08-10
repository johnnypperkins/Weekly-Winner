//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import Kingfisher

struct groupsView: View {
    @State private var isJoinSheetPresented = false
    @State private var isGroupSettingsViewPresented: Bool = false
    @State private var searchText = ""
    @State private var isShowingSheet = false
    @State private var isShowingSheetTicket = false
    @ObservedObject private var viewModel = groupsViewModel()
    @ObservedObject private var chatVM = chatViewModel()
    @State private var selectedGroup = 1
    @State private var showingChat: Bool = false
    @State private var whichWeek: Int = 0
    //@State private var groupsFetched = false

    init() {
//        viewModel.fetchUserTickets() {
//            viewModel.fetchUserGroups() {}
//        }
        
        viewModel.fetchRankedTickets(groupID: "Global") {}
    }
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                searchText
            },
            set: {
                searchText = $0
                viewModel.fetchGroup(from: searchText)
            }
        )
        NavigationStack {
            if (viewModel.userTickets.count > 0) {
                VStack {
                    if viewModel.userTickets.count <= 2 {
                        ZStack {
                                Button(action: {
                                    selectedGroup = 0
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .frame(width: 45, height: 30, alignment: .center)
                                        .background(selectedGroup == 0 ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                        .cornerRadius(5)
                                    Spacer()
                                }
                                    Spacer()
                                    HStack {
                                        ForEach(1..<viewModel.userTickets.count+1, id: \.self) { index in
                                            Button(action: {
                                                self.selectedGroup = index
                                                viewModel.canGetHistoricalData = false
                                                viewModel.fetchRankedTickets(groupID: viewModel.userTickets[index-1].groupID) {
                                                    //viewModel.fetchUserGroups(completion: <#T##() -> Void#>)
                                                }
                                                showingChat = false
                                                print("\(selectedGroup) is selected")
                                            }) {
                                                Text(viewModel.userTickets[index-1].groupName)
                                                    .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                                    .foregroundColor(.white)
                                                    .frame(width: 105, height: 30, alignment: .center)
                                                    .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                                    .cornerRadius(5)
                                            }
                                        }
                                    }
                                Spacer()

                        }.padding(.horizontal, 10)
                        
                    } else {
                        
                        HStack(spacing: 10) {
                            Button(action: {
                                selectedGroup = 0
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .frame(width: 45, height: 30, alignment: .center)
                                    .background(selectedGroup == 0 ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                    .cornerRadius(5)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(1..<viewModel.userTickets.count+1, id: \.self) { index in
                                        
                                        Button(action: {
                                            self.selectedGroup = index
                                            viewModel.fetchRankedTickets(groupID: viewModel.userTickets[index-1].groupID) {}
                                            showingChat = false
                                            print("\(selectedGroup) is selected")
                                        }) {
                                            Text(viewModel.userTickets[index-1].groupName)
                                                .font(.custom(K.customFonts.lexendDecaLight, size: 16))
                                                .foregroundColor(.white)
                                                .frame(width: 105, height: 30, alignment: .center)
                                                .background(selectedGroup == index ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                                .cornerRadius(5)
                                        }
                                        
                                    }
                                }
                        }
                        
                        }.padding(.horizontal, 16)
                    
                    }
                    if selectedGroup == 0 {
                       
                        
                        Text("Search Group")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 20).weight(.medium))
                            .foregroundColor(.white)
                            .padding(.top,20)
                        
                        SearchBar(text: keywordBinding, placeholder: "Search Groups")
                        if (viewModel.userTickets.count >= P.maxNumGroupsCanJoin) {
                            Text("Max Groups Joined")
                                .foregroundColor(Color.red)
                        }
                        ZStack{
                            if !viewModel.queriedGroups.isEmpty {
                                withAnimation {
                                    ScrollView {
                                        ForEach(viewModel.queriedGroups, id: \.id) { group in
                                            if (viewModel.userTickets.count < P.maxNumGroupsCanJoin) {
                                                Button(action: {
                                                    // Destination view code
                                                    isJoinSheetPresented.toggle()
                                                }) {
                                                    groupBarView(group: group)
                                                }.sheet(isPresented: $isJoinSheetPresented) {
                                                    GroupJoinSheet(group: group, viewModel: viewModel, isPresented: $isJoinSheetPresented)
                                                }
                                            } else {
                                                groupBarView(group: group)
                                            }
                                        }
                                        
                                    }
                                }.animation(.easeInOut, value: 20)
                            }
                            VStack {
                                Spacer()
                                Button {
                                    print(viewModel.userTickets)
                                    isShowingSheet.toggle()
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
                        }
                        
                    }
                    else{
                        ZStack {
                            HStack{
                                Image(systemName: "photo.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                                
                                Text(viewModel.userTickets[selectedGroup-1].groupName)
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18).weight(.medium))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                Spacer()
                                
                                if(viewModel.userTickets[selectedGroup-1].groupID != "Global") {
                                    Button(action: {
                                                isGroupSettingsViewPresented = true
                                            }) {
                                                Image(systemName: "gearshape")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .padding()
                                                    .foregroundColor(.white)
                                            }
                                            .sheet(isPresented: $isGroupSettingsViewPresented) {
                                                groupSettingsView(selectedGroup: $selectedGroup, viewModel: viewModel, groupAdmin: viewModel.userTickets[selectedGroup-1].groupAdmin)
                                                
                                            }
                                }
                                
                            }.padding(.bottom)
                                .padding(.horizontal,16)
                            HStack {
                                Text(showingChat ? "Chat" : "Members")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16).weight(.medium))
                                    .foregroundColor(.white)
                                if (viewModel.canGetHistoricalData) {
//                                    Picker("Which Week", selection: $whichWeek) {
//                                        ForEach(0..<viewModel.totalArrayOfDates[selectedGroup-1].count, id: \.self) { index in
//                                            Text(viewModel.totalArrayOfDates[selectedGroup-1][index])
//                                                .foregroundColor(.white)
//                                        }
//                                    }.pickerStyle(MenuPickerStyle())
                                }
                                Spacer()
                                Button(action: {
                                    showingChat = false
                                }) {
                                    Image(systemName: showingChat ? "ticket.fill" : "ticket") // Assuming "ticket" and "ticket.fill" are your symbols
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(showingChat ? .gray : .blue)
                                }
                                Button(action: {
                                    showingChat = true
                                }) {
                                    Image(systemName: showingChat ? "message.fill" : "message") // Assuming "message" and "message.fill" are your symbols
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(showingChat ? .blue : .gray)
                                }
                            }.padding(EdgeInsets(top: 80, leading: 16, bottom: 0, trailing: 16))
                            
                        }
                        
                        Divider().padding(.horizontal)
                        VStack(alignment: .leading, spacing: 0) {
                            if !showingChat {
                                leaderboardView(viewModel: viewModel, selectedGroup: $selectedGroup)
                            } else {
                                chatView(viewModel: chatVM, selectedGroup: $selectedGroup, groupsViewModel: viewModel)
                            }
                            // .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius to the ScrollView
                            
                            
                        }
                        .padding(.horizontal,16)
                        //.clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius to the ScrollView
                        
                    }
                    Spacer()
                }
                .sheet(isPresented: $isShowingSheet, content: {
                    createGroupsView()
                })
                .onChange(of: isShowingSheet) { newValue in
                    if newValue == false {
                        // The sheet was dismissed
                        selectedGroup = 1
                        print("onChange ranked")
                        viewModel.fetchRankedTickets(groupID: viewModel.userTickets[selectedGroup-1].groupID) {}
                    }
                }
                .onAppear(){
                    if selectedGroup > 0 {
                        print("on appear ranked")
                        viewModel.fetchRankedTickets(groupID: viewModel.userTickets[selectedGroup-1].groupID) {
                            viewModel.getGroupAdmin(groupID: viewModel.userTickets[selectedGroup-1].groupID) // keeps saying index out of range
                        }
                    }
                }
            }
        }.navigationTitle("Groups")
            .onAppear() {
                viewModel.fetchUserTickets() {
                    viewModel.fetchUserGroups {}
                }
            }.padding(.top, 75)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
    }
}

struct groupBarView: View {
    
    var group: Group // Groups99
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    if group.groupImageURL != ""{
                        KFImage(URL(string: group.groupImageURL))
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .cornerRadius(25)
                            .frame(width: 40, height: 40, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("\(group.groupName)")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            if group.password != "" {
                                Text("Private Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                            else{
                                Text("Public Group")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                    .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                                    .frame(alignment: .top)
                            }
                        }.frame(minWidth: 0, maxWidth: .infinity)
                        
                        Text("\(group.groupSlogan)")
                            .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                              .foregroundColor(.white)
                    }
                    Spacer()
                    
                }
                HStack {
                    Text("Group Admin")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                      .foregroundColor(.white)
                    Spacer()
                    Text(group.groupAdmin)
                      .font(Font.custom(K.customFonts.lexendDecaLight, size: 14).weight(.light))
                      .foregroundColor(.white)
                }
                .padding(.top,10)

                HStack{
                    Spacer()
                    
                    Text("Join")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 16))
                        .foregroundColor(.white)
                                    //shadow
                    
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 40 , maxHeight: 40)
                    .background(Color(red: 0.31, green: 0.57, blue: 1))
                    .cornerRadius(10)
                    .padding(.top,10)
                
            }.frame(minWidth: 0, maxWidth: .infinity)
                .padding(.horizontal,15)
                .padding(.vertical,20)
        }
        .background(Color(red: 0.13, green: 0.14, blue: 0.34))
        .cornerRadius(10)
        .padding(.horizontal,16)
    }
}

struct leaderboardView: View {
    @ObservedObject var viewModel: groupsViewModel
    @Binding var selectedGroup: Int
    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<viewModel.rankedGroupTickets.count, id: \.self) { index in
                    if (viewModel.rankedGroupTickets[index].uid != Auth.auth().currentUser?.uid) {
                        NavigationLink(destination: ticketView(username: viewModel.rankedGroupTickets[index].username, uid: viewModel.rankedGroupTickets[index].uid, groupID: viewModel.rankedGroupTickets[index].groupID), label: {
                            BetCard(viewModel: viewModel, ticket: viewModel.rankedGroupTickets[index], rank: (viewModel.rankedGroupTickets[index].rank), ownCard: false).padding(.bottom,16)
                        }).id(UUID())
                    } else {
                        // doesnt click if its yourself
                        BetCard(viewModel: viewModel, ticket: viewModel.rankedGroupTickets[index], rank: (viewModel.rankedGroupTickets[index].rank), ownCard: true).padding(.bottom,16)

                    }
                }
            }.onAppear(){
                viewModel.printTickets(ticket: viewModel.rankedGroupTickets)
                
            }
        }
        .refreshable {
            await viewModel.fetchUserTickets() {}
            if selectedGroup != 0 {
                print("refresh ranked")
                viewModel.fetchRankedTickets(groupID: viewModel.userTickets[selectedGroup-1].groupID) {}
            }
        }.onAppear() {
            print("\(viewModel.rankedGroupTickets.count) is count")
        }
    }
    
}




struct BetCard: View {
    @ObservedObject var viewModel: groupsViewModel
//    @ObservedObject var profileViewModel: profileViewModel
    let ticket: Ticket
    let rank: String
    let ownCard: Bool
    @State private var profileImageURL = ""
    var adminCard: Bool {
        if ticket.groupAdmin == ticket.uid {
            return true
        } else {
            return false
        }
    }
    @State private var isEnabled: Bool = false // New State variable
//    @State private var oldValue: Bool = false

    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                HStack {
                    HStack(spacing: 11) {
                        HStack(spacing: 0) {
                            if rank == "1" || rank == "T1"{
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color(hex: "D4AF37"))
                            } else if rank == "2" || rank == "T2" {
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color(hex: "C0C0C0"))
                            }
                            else if rank == "3" || rank == "T3" {
                                Image(systemName: "trophy.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(Color(hex: "9F7A34"))
                            }
                            Text(rank)
                                .font(Font.custom(K.customFonts.poppinsMedium, size: 12).weight(.medium))
                                .foregroundColor(.white)
                                .padding(.leading,3)
                        }
                        .frame(maxHeight: .infinity)
                        HStack(spacing: 5) {
                            KFImage(URL(string: profileImageURL))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 24, height: 24)
                            
                            Text("\(ticket.username)")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(height: 24)
                    
                    Spacer()
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(ticket.totalPotentialWon) PW")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
                            .foregroundColor(Color(red: 0.83, green: 0.47, blue: 0.07))
                        Text("\(ticket.totalWon) TW")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12).weight(.light))
                            .foregroundColor(Color(red: 0.24, green: 0.86, blue: 0.02))
                    }
                    .frame(maxHeight: .infinity)
                    
                    
                    
                    // Arrow
                    
                    HStack {
                        Image(systemName: "chevron.right") // Use any image you'd like
                            .resizable()
                            .frame(width: 7.5, height: 10) // Adjust size to your liking
                            .foregroundColor(!ownCard && ticket.isEnabled ? .white : .clear) // Choose color
                        //.padding(.trailing,2.5) // Add padding to move away from the edge
                    }
                    
                }.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                HStack {
                    Spacer()
                    if(!ownCard && ticket.groupAdmin == Auth.auth().currentUser?.uid) {
                        Button(ticket.isEnabled ? "Enabled" : "Disabled", action: {
                            viewModel.updateIsEnabled(ticket: self.ticket, isEnabled: ticket.isEnabled ? false : true) {_ in
                                viewModel.fetchRankedTickets(groupID: ticket.groupID) {}
                            }
                        }).foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaLight, size: 12))
//                        .foregroundColor(!ticket.isEnabled ? Color.red : K.darkGreen)
                    }
                    Spacer()
                }.background(!ticket.isEnabled ? K.finalColor.deleteRed : K.finalColor.winningGreen)
                    //.padding(.bottom,10)

            }
        }
        .opacity(ticket.isEnabled || ticket.groupAdmin == Auth.auth().currentUser?.uid ? 1 : 0.66)
        .padding(.vertical, 10)
        .frame(minWidth: 0,maxWidth: .infinity, minHeight: 44, maxHeight: ticket.groupAdmin != Auth.auth().currentUser?.uid || ticket.username == UserData.shared.username ? 44 : 64)
        .background(!ownCard ? Color(red: 0.13, green: 0.14, blue: 0.34) : K.cadetBlue.opacity(0.25) )
        .cornerRadius(10)
        
        .onAppear {
            isEnabled = ticket.isEnabled
            print(ticket.uid)
            viewModel.fetchUserProfilePic(uid: ticket.uid) { (profileImageUrl, error) in
                if let error = error {
                    print("Error fetching profile image URL: \(error)")
                   
                } else if let profileImageUrl = profileImageUrl {
                    print("Profile image URL: \(profileImageUrl)")
                    self.profileImageURL = profileImageUrl
                }
            }
        }
    }
}



struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
        }
        .padding(.top, 10)
    }
}




struct GroupJoinSheet: View {
    let group: Group // Groups99
    let viewModel: groupsViewModel
    @Binding var isPresented: Bool
    @State var canJoin = true
    @State var adminUsername = ""
    @ObservedObject private var authVM = authenticationViewModel()
    

    var body: some View {
        
        VStack {
            if (canJoin) {
                Text("Join Group")
                    .font(.title)
                    .fontWeight(.bold)
            }

            VStack {
                if let imageURL = URL(string: group.groupImageURL), let imageData = try? Data(contentsOf: imageURL), let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 3)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 3)
                }
            }
            Text(group.groupName)
                .font(.headline)
            Text(group.groupSlogan)
                .font(.subheadline)
            Text("Admin: \(adminUsername)")
                .font(.caption)
            if (canJoin) {
                Button(action: {
                    viewModel.joinGroup(group: group)
                    isPresented = false
                }, label: {
                    Text("Join Group")
                })
                .padding()
            } else {
                Text("Already Joined")
                    .padding()
            }
            
        }
        .padding()
        .onAppear() {
            viewModel.checkIfGroupAlreadyJoined(group: group) { (alreadyJoined) in
                if !alreadyJoined {
                    canJoin = true
                } else {
                    canJoin = false
                }
            }
            authVM.fetchUserInformation(uid: group.groupAdmin) { (user) in
                if let user = user {
                    adminUsername = user.username
                } else {
                    adminUsername = group.groupAdmin
                }
            }
        }
    }
}

struct chatView: View {
    @ObservedObject var viewModel: chatViewModel
    @Binding var selectedGroup: Int
    @ObservedObject var groupsViewModel: groupsViewModel
    @State private var chatMessage: String = "" // State variable to hold the chat message
    //@State private var isChatsLoaded: Bool = false


    var body: some View {
        

        VStack {
            if viewModel.isChatsLoaded {
                HStack {
                    TextField("Enter your message", text: $chatMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                        .submitLabel(.send) // setting the return key to "send"
                        .onSubmit { // submit action
                            submitMessage()
                        }

                    Button(action: {
                        submitMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                }

                ScrollView {
                    ForEach(0..<viewModel.allChats.count, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(viewModel.allChats[index].username)").padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                                    .font(.custom(K.customFonts.poppinsMedium, size: 8))
                                    .foregroundColor(K.finalColor.textWhite)
                                Text("\(viewModel.allChats[index].messageContent)")
                                    .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                                    .font(.custom(K.customFonts.poppinsMedium, size: 15))
                                    .foregroundColor(K.finalColor.textWhite)
                                    .background(K.finalColor.backgroundBlue)
                                    .cornerRadius(5)
                                    
                            }.padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                            
                        Spacer()
                            Text("\(formatDate.format(date: viewModel.allChats[index].timeSent))").font(.custom(K.customFonts.poppinsMedium, size: 8))
                                .foregroundColor(K.finalColor.textWhite)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 5))
                        }
                    }
                    
                }.frame(height: 400)
                    .background(K.finalColor.cardBlue)
                    .cornerRadius(10)
                    //.scrollPosition(initialAnchor: .bottom)
                    
            }
            
            
        }.padding()
        .onAppear() {
            viewModel.getChats(groupID: groupsViewModel.userTickets[selectedGroup-1].groupID) {_ in
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mma"
        }
    }

    
    func submitMessage() {
        if !chatMessage.isEmpty {
            viewModel.uploadChat(message: chatMessage, groupID: groupsViewModel.userTickets[selectedGroup-1].groupID)
            chatMessage = "" // clear the text field
            hideKeyboard() // hide keyboard
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
