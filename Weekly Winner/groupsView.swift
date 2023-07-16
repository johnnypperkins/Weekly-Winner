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

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
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
                
                SearchBar(text: $searchText, placeholder: "Search Groups")
                
                List {
                    Section(header: Text("My Groups")) {
                        ForEach(myGroups.filter { searchText.isEmpty ? true : $0.contains(searchText) }, id: \.self) { group in
                            Text(group)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet, content: {
                createGroupsView()
            })
            .navigationTitle("Groups")
            
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

struct groupsView_Previews: PreviewProvider {
    static var previews: some View {
        groupsView()
    }
}
