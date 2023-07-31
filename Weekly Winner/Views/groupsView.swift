//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct groupsView: View {
    @State private var isJoinSheetPresented = false
    @State private var searchText = ""
    @State private var isShowingSheet = false
    @State private var isShowingSheetTicket = false
    @ObservedObject private var viewModel = groupsViewModel()
    @State private var selectedGroup = 1
    //@State private var groupsFetched = false

    init() {
        viewModel.fetchUserTickets() {}
    
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
                    Picker("Group", selection: $selectedGroup) {
                        ForEach(0..<viewModel.userTickets.count+1, id: \.self) { index in
                            if index == 0 {
                                Image(systemName: "plus")
                            }
                            else{
                                Text("\(viewModel.userTickets[index-1].groupName)").tag(index)
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10)
                    .onChange(of: selectedGroup) { newValue in
                        if selectedGroup > 0 {
                            viewModel.fetchRankedTickets(groupID: viewModel.userTickets[selectedGroup-1].groupID) {
                               
                            }
                        }
                        print("\(selectedGroup) is selected")
                        print("\(newValue) is NV")
                    }
                    
                    if selectedGroup == 0 {
                        HStack {
                            Spacer()
                            
                            Button {
                                print(viewModel.userTickets)
                                isShowingSheet.toggle()
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .foregroundColor(.green)
                                
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        
                        Text("Find Group")
                            .font(.title)
                            .bold()
                        
                        SearchBar(text: keywordBinding, placeholder: "Search Groups")
                        if (viewModel.userTickets.count >= P.maxNumGroupsCanJoin) {
                            Text("Max Groups Joined")
                                .foregroundColor(Color.red)
                        }
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
                    }else{
                        HStack{
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .frame(width: 50,height: 50)
                                .padding()
                                .foregroundColor(.blue)
                            VStack{
                                Text(viewModel.userTickets[selectedGroup-1].groupName)
                                    .font(.title2)
                            }
                            if(viewModel.userTickets[selectedGroup-1].groupID != "global") {
                                Button(action: {
                                    selectedGroup -= 1
                                    viewModel.leaveGroup(ticket: viewModel.userTickets[selectedGroup]) {
                                    }
                                }) {
                                    Text("Leave Group") // will add design later obv
                                }
                            }
                        }
                        Divider().padding(.horizontal)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Rank")
                                    .font(.headline)
                                    .foregroundColor(K.darkBlue)
                                    .frame(width: 100, alignment: .leading)
                                Spacer()
                                Text("PW")
                                    .foregroundColor(K.darkGreen)
                                    .frame(width: 50, alignment: .leading)
                                Text("TW")
                                    .foregroundColor(.green)
                                    .frame(width: 50, alignment: .leading)
                            }
                            .padding(EdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0))
                            .padding(.horizontal)
                            .background(K.veryLightBlue) // changes color based on bet result
                            .frame(maxWidth: .infinity) // Move the frame to the bottom
                            .clipShape(RoundSomeCorners(topLeft: 10,topRight: 10,bottomLeft: 0,bottomRight: 0))
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(0..<viewModel.rankedGroupTickets.count, id: \.self) { index in
                                        let ticket = viewModel.rankedGroupTickets[index]
                                        
                                        if (ticket.uid != Auth.auth().currentUser?.uid) {
                                            NavigationLink(destination: ticketView(username: ticket.username, uid: ticket.uid, groupID: ticket.groupID), label: {
                                                BetCard(viewModel: viewModel, ticket: ticket, rank: (ticket.rank), ownCard: false)
                                                    .clipShape(RoundSomeCorners(
                                                        topLeft: index == viewModel.rankedGroupTickets.count - 1 ? 0 : 0,
                                                        topRight: index == viewModel.rankedGroupTickets.count - 1 ? 0 : 0,
                                                        bottomLeft: index == viewModel.rankedGroupTickets.count - 1 ? 10 : 0,
                                                        bottomRight: index == viewModel.rankedGroupTickets.count - 1 ? 10 : 0
                                                    ))
                                            }).id(UUID())
                                        } else { // doesnt click if its yourself
                                            BetCard(viewModel: viewModel, ticket: ticket, rank: (ticket.rank), ownCard: true)
                                                .clipShape(RoundSomeCorners(
                                                    topLeft: index == viewModel.rankedGroupTickets.count - 1 ? 0 : 0,
                                                    topRight: index == viewModel.rankedGroupTickets.count - 1 ? 0 : 0,
                                                    bottomLeft: index == viewModel.rankedGroupTickets.count - 1 ? 10 : 0,
                                                    bottomRight: index == viewModel.rankedGroupTickets.count - 1 ? 10 : 0
                                                ))
                                        }
                                        if index != viewModel.rankedGroupTickets.count - 1 {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .refreshable {
                                await viewModel.fetchUserTickets() {}
                                if selectedGroup != 0 {
                                    print("refresh ranked")
                                    viewModel.fetchRankedTickets(groupID: viewModel.userTickets[selectedGroup-1].groupID) {}
                                }
                            }
                            
                            // .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius to the ScrollView
                            
                            
                        }
                        .padding(.horizontal)
                        .padding(.horizontal)
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
                }
            }.padding(.top, 75)
    }
}


struct BetCard: View {
    @ObservedObject var viewModel: groupsViewModel
    let ticket: Ticket
    let rank: String
    let ownCard: Bool
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
            HStack {
                if(!ownCard && ticket.groupAdmin == Auth.auth().currentUser?.uid) {
//                    Toggle(isOn: Binding(get: { self.ticket.isEnabled }, set: { newValue in
//                        viewModel.updateIsEnabled(ticket: self.ticket, isEnabled: newValue) {_ in }
//                    })) {
//                        Text("Enabled")
//                    }
                    Button(ticket.isEnabled ? "E" : "D", action: {
                        viewModel.updateIsEnabled(ticket: self.ticket, isEnabled: ticket.isEnabled ? false : true) {_ in
                            viewModel.fetchRankedTickets(groupID: ticket.groupID) {}
                        }
                    }).foregroundColor(!ticket.isEnabled ? Color.red : K.darkGreen)
                }

                Text("\(rank). \(ticket.username) \(adminCard ? "(A)" : "")")
                    .font(.subheadline)
                    .foregroundColor(K.darkBlue)
                    .frame(width: 150, alignment: .leading)
                    .lineLimit(1)
                Spacer()
                Text("\(ticket.totalPotentialWon)")
                    .foregroundColor(K.darkGreen)
                    .frame(width: 50, alignment: .leading)
                Text("\(ticket.totalWon)")
                    .foregroundColor(.green)
                    .frame(width: 50, alignment: .leading)
            }
            .padding()
            .background(!ownCard ? K.veryLightGray : K.cadetBlue.opacity(0.25)) // changes color based on bet result
            .frame(maxWidth: .infinity) // Move the frame to the bottom
            .opacity(ticket.isEnabled || ticket.groupAdmin == Auth.auth().currentUser?.uid ? 1 : 0.66)
            
            // Arrow
            if (!ownCard && ticket.isEnabled) {
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right") // Use any image you'd like
                        .resizable()
                        .frame(width: 10, height: 15) // Adjust size to your liking
                        .foregroundColor(.gray) // Choose color
                        .padding(.trailing,7.5) // Add padding to move away from the edge
                }
            }
        }
        .onAppear {
            isEnabled = ticket.isEnabled
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


struct groupBarView: View {
    
    var group: Group // Groups99
    var body: some View {
        ZStack{
            
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.2))
            HStack{
                //KFImage(URL(string: user.profileImageUrl))
//                    .resizable()
//                    .cornerRadius(25)
//                    .frame(width: 50, height: 50, alignment: .leading)
                
                VStack {
                    Text("\(group.groupName)")
                        .bold()
                    
                    Text("\(group.groupSlogan)")
                        .foregroundColor(Color(.blue))
                }
                Spacer()
            }
            .frame(alignment: .leading)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .cornerRadius(13)
        .padding(.horizontal)
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


struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
