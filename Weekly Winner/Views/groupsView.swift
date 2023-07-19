//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct groupsView: View {
    @State private var searchText = ""
    @State private var myGroups = ["Group 1", "Group 2", "Group 3"] // Replace with your data source
    @State private var isShowingSheet = false
    @ObservedObject private var viewModel = groupsViewModel()
    @State private var selectedGroup = 0

    init() {
        viewModel.fetchGroupNames()
        viewModel.fetchGroupTickets(group: "global")
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
            VStack {
                Picker("Group", selection: $selectedGroup) {
                    ForEach(0..<viewModel.groupNames.count, id: \.self) { index in
                        Text(viewModel.groupNames[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 10)
                .onChange(of: selectedGroup) { newValue in
                    viewModel.fetchGroupTickets(group: viewModel.groupNames[selectedGroup])
                }
                
                ForEach(viewModel.rankedGroupTickets) { game in // HARDCODE NCAAF
                    Button {
                        
                    } label: {
                        Text(game.groupName)
                    }

                }.padding()
                
                //                HStack {
                //                    Spacer()
                //
                //                    Button {
                //                        isShowingSheet.toggle()
                //                    } label: {
                //                        Image(systemName: "plus")
                //                            .resizable()
                //                            .frame(width: 30, height: 30)
                //                            .padding()
                //                            .foregroundColor(.green)
                //
                //                    }
                //                }
                //                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                //
                //                SearchBar(text: keywordBinding, placeholder: "Search Groups")
                //                if !viewModel.queriedGroups.isEmpty {
                //                    withAnimation {
                //                        ScrollView {
                //                            ForEach(viewModel.queriedGroups, id: \.id) { group in
                //                                NavigationLink(destination: {
                //                                    // Destination view code
                //                                }) {
                //                                    groupBarView(ticket: group)
                //                                }
                //                            }
                //                        }
                //                    }.animation(.easeInOut, value: 20)
                //                }
                //            }
                //            .sheet(isPresented: $isShowingSheet, content: {
                //                createGroupsView()
                //            })
            }
            .navigationTitle("Groups")
            .refreshable {
                await viewModel.fetchGroupNames()
                viewModel.fetchGroupTickets(group: viewModel.groupNames[selectedGroup])
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
                        .foregroundColor(Color("Color 1"))
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

struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
