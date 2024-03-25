//
//  addFriendsView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 3/25/24.
//

import SwiftUI
import Kingfisher

struct addFriendsView: View {
    @State var isPresented: Bool = false
    @StateObject var userLookup = addFriendsViewModel()
    @State var keyword: String = ""
    @State private var zRotateAnimation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let keywordBinding = Binding<String> (
            get: {
                keyword
            },
            set: {
                keyword = $0
                userLookup.fetchUser(from: keyword)
            }
        )
        VStack {
            HStack {
                Button {
                    // 2
                    dismiss()
                    
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 10,height: 15)
                    }   .padding(.leading)
                }
                Spacer()
            }.padding()
            
            
            searchBarView(keyword: keywordBinding)
              
            
            ScrollView {
                if keyword == "" {
//                    Image("Logo")
//                        .resizable().aspectRatio(contentMode: .fit)
//                        .frame(width: 200, height: 200)
//                        .rotationEffect(.degrees(zRotateAnimation ? 360 : 0))
//                        .animation(Animation.linear(duration: 50).speed(5)
//                            .repeatForever(autoreverses: true),
//                                   value: self.zRotateAnimation)
//                        .padding()// << link to state
//                        .onAppear() {
//                            self.zRotateAnimation.toggle()
//                        }
                    
                    Text("Add friends to start competing now!")
                        .font(Font.custom(K.customFonts.lexendDecaMedium, size: 18).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.top,40)
                }
                ForEach(userLookup.queriedUsers, id: \.id) { user in
                    NavigationLink(destination: {
                        profileView(user: user)}, label: {
                            profileBarView(user: user)
                        
                        }).id(UUID())
                }
            }
            
            
            //Spacer()
            
            Spacer()
        }.background(Color(red: 0.02, green: 0.05, blue: 0.26))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
    }
}

//struct connectView_Previews: PreviewProvider {
//    static var previews: some View {
//        connectView()
//    }
//}

