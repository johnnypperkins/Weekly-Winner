//
//  screen5.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

struct screen5: View {
    @State private var showMenu = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Hello, World!")
                        .navigationBarTitle("Screen 5", displayMode: .inline)
                        .navigationBarItems(trailing: Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                                .font(Font.title.weight(.bold)) // Make the lines thicker
                                .foregroundColor(showMenu ? .white : .black) // Change color based on whether the menu is shown or not
                        })
                }
                if showMenu {
                    SideMenuView(showMenu: $showMenu)
                }
            }
        }
    }
}

struct SideMenuView: View {
    @Binding var showMenu: Bool

    var body: some View {
        HStack {
            Spacer()
            VStack (alignment: .leading, spacing: 5){

                NavigationLink(destination: SettingsView()) {
                    SideMenuButton(title: "Settings")
                }
                NavigationLink(destination: RulesView()) {
                    SideMenuButton(title: "Rules")
                }
                NavigationLink(destination: ContactView()) {
                    SideMenuButton(title: "Contact")
                }

                Spacer()
                Spacer() // Add extra spacer at the bottom to move buttons up
            }
            .padding()
            .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
            .background(Color.gray.edgesIgnoringSafeArea(.all))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
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

struct Screen5_Previews: PreviewProvider {
    static var previews: some View {
        screen5()
    }
}
