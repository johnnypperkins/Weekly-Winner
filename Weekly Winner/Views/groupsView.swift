//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct groupsView: View {
    @State private var isJoinSheetPresented = false
    @State private var searchText = ""
    @State private var myGroups = ["Group 1", "Group 2", "Group 3"] // Replace with your data source
    @State private var isShowingSheet = false
    @ObservedObject private var viewModel = groupsViewModel()
    @State private var selectedGroup = 0

    init() {
        viewModel.fetchGroupNames()
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
            ScrollView{
                VStack {
                    Picker("Group", selection: $selectedGroup) {
                        ForEach(0..<viewModel.groupNames.count+1, id: \.self) { index in
                            if index == 0 {
                                Image(systemName: "plus")
                            }
                            else{
                                Text("\(viewModel.groupNames[index-1].groupName)").tag(index)
                                
                                
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 10)
                    .onChange(of: selectedGroup) { newValue in
                        if selectedGroup > 0 {
                            viewModel.fetchGroupTickets(group: viewModel.groupNames[selectedGroup-1].groupName)
                        }
                    }
                    
                    
                    if selectedGroup == 0 {
                        HStack {
                            Spacer()
                            
                            Button {
                                print(viewModel.groupNames)
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
                        if !viewModel.queriedGroups.isEmpty {
                            withAnimation {
                                ScrollView {
                                    ForEach(viewModel.queriedGroups, id: \.id) { group in
                                        Button(action: {
                                            // Destination view code
                                            isJoinSheetPresented.toggle()
                                        }) {
                                            groupBarView(ticket: group)
                                        }.sheet(isPresented: $isJoinSheetPresented) {
                                            GroupJoinSheet(ticket: group, viewModel: viewModel, isPresented: $isJoinSheetPresented)
                                        }
                                    }
                                }
                            }.animation(.easeInOut, value: 20)
                        }
                        
                    }
                    else{
                        
                        HStack{
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .frame(width: 100,height: 100)
                                .padding()
                                .foregroundColor(.blue)
                            VStack{
                                Text(viewModel.groupNames[selectedGroup-1].groupName)
                                    .font(.title2)
                            }
                        }
                        Divider()
                        
                        ForEach(viewModel.rankedGroupTickets) { game in // HARDCODE NCAAF
                            VStack(alignment: .leading, spacing: 0) {
                                BetCard(group: game, viewModel: viewModel)
                                    .clipShape(RoundedCorners())
                                
                            
                            }
                            
                        }.padding(.top)
                    }
                    
                    
                    Spacer()
                }
                .sheet(isPresented: $isShowingSheet, content: {
                    createGroupsView()
                })
                
            }
            .navigationTitle("Groups")
            .refreshable {
                await viewModel.fetchGroupNames()
                if selectedGroup != 0 {
                    viewModel.fetchGroupTickets(group: viewModel.groupNames[selectedGroup-1].groupName)
                }
            }
            
        }
    }
}


struct BetCard: View {
    let group: Group
    @ObservedObject var viewModel: groupsViewModel

    var body: some View {
        HStack {
            Text("\(group.groupNumber)")
                    .font(.headline)
                    .foregroundColor(K.darkBlue)
                Spacer()
            Text("Projected \(group.totalPotentialWon)")
                    .foregroundColor(K.darkGreen)
            Text("\(group.totalWon)")
                .foregroundColor(.green)
        }.clipShape(RoundedCorner())
        .padding()
        .frame(maxWidth: .infinity) // Move the frame to the bottom
        .background(Color(.lightGray)) // changes color based on bet result
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
    
    var ticket: Ticket
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
                    Text("\(ticket.groupName)")
                        .bold()
                    
                    Text("\(ticket.groupSlogan)")
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
    let ticket: Ticket
    let viewModel: groupsViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("Join Group")
                .font(.title)
                .fontWeight(.bold)
            VStack {
                if let imageURL = URL(string: ticket.groupImageURL), let imageData = try? Data(contentsOf: imageURL), let image = UIImage(data: imageData) {
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
            Text(ticket.groupName)
                .font(.headline)
            Text(ticket.groupSlogan)
                .font(.subheadline)
            Text("Admin: \(ticket.groupAdmin)")
                .font(.caption)
            Button("Join Group") {
                // Implement the join group functionality here
                viewModel.joinGroup(groupName: ticket.groupName)
                isPresented = false
                
            }
            .padding()
        }
        .padding()
    }
}


struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
