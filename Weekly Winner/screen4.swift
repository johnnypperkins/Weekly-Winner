//
//  screen4.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct Group1: Identifiable {
    let id = UUID()
    let name: String
    let members: [String]
}

struct GroupMembersView: View {
    let group: Group1
    
    var body: some View {
        VStack {
            Text("Group Members")
                .font(.title)
                .padding()
            
            List(group.members, id: \.self) { member in
                Text(member)
            }
        }
    }
}

struct screen4: View {
    @State private var searchText = ""
    @State private var selectedGroup: Group1?
    
    let groups: [Group1] = [
        Group1(name: "Group 1", members: ["Member 1", "Member 2", "Member 3"]),
        Group1(name: "Group 2", members: ["Member 4", "Member 5", "Member 6"]),
        Group1(name: "Group 3", members: ["Member 7", "Member 8", "Member 9"])
    ]
    
    var filteredGroups: [Group1] {
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                List(filteredGroups) { group in
                    Button(action: {
                        selectedGroup = group
                    }) {
                        Text(group.name)
                    }
                }
            }
            .navigationBarTitle("Groups")
        }
        .sheet(item: $selectedGroup) { group in
            GroupMembersView(group: group)
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct screen4_Previews: PreviewProvider {
    static var previews: some View {
        screen4()
    }
}
