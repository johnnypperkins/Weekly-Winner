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
    @StateObject private var viewModel = createGroupsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
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
                    viewModel.createGroup(groupName: groupName, groupSlogan: groupSlogan, password: password)
                    dismiss()
                }) {
                    Text("Create Group")
                }
            }
            .navigationBarTitle("Create Group", displayMode: .inline)
        }
    }
}

struct createGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        createGroupsView()
    }
}
