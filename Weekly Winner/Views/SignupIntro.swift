//
//  SignupIntro.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 11/10/23.
//

import SwiftUI
import WebKit



struct SignupIntro: View {
    @State var offset: CGFloat = 0
    @State  var pageIndex: Int = 0
    
    var colors: [Color] = [.red,.blue,.pink]
    
    
    var body: some View {
//        ScrollView(.init()){
        VStack{
            HStack{
                Text("WagerPool")
                    .font(.custom(K.customFonts.lexendDecaSB, size: 35))
                    .foregroundColor(K.finalColor.titleBlue)
                Spacer()
                if pageIndex < 2 {
                    Button {
                        
                    } label: {
                        HStack{
                            
                            Spacer()
                            
                            Text("Skip")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                .foregroundColor(.white)
                            //shadow
                            
                            Spacer()
                        }.frame(minWidth: 0, maxWidth: 60, minHeight: 30 , maxHeight: 30)
                            .background(Color(red: 0.31, green: 0.57, blue: 1))
                            .cornerRadius(10)
                            .padding(16)
                    }
                }
            }.padding(.leading,15)
            TabView(selection: $pageIndex){
                Intro1(pageIndex: $pageIndex)
                    .tag(0)
                Intro2(pageIndex: $pageIndex)
                    .tag(1)
                Intro3(pageIndex: $pageIndex)
                    .tag(2)
                //                ForEach(colors.indices, id: \.self) { index in
                //
                //                    Text("Hello world")
                //                }
            }.shadow(color: .black, radius: 10, x: 2, y: 2)
            .animation(.easeInOut, value: pageIndex)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
            HStack{
                Spacer()
                if pageIndex < 2 {
                    Button {
                        pageIndex += 1
                    } label: {
                        Image(systemName: "arrow.forward")
                            .resizable()
                            .frame(width: 35, height: 30)
                            .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                    }
                } else {
                    NavigationLink {
                        
                    } label: {
                        Text("Continue")
                            .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                            .foregroundColor(.white)
                        //shadow
                        
                       
                    }.frame(minWidth: 0, maxWidth: 80, minHeight: 40 , maxHeight: 40)
                        .background(Color(red: 0.31, green: 0.57, blue: 1))
                        .cornerRadius(10)
                    
                }
            }.padding(.horizontal, 25)
                .padding(.top,20)
                .padding(.bottom,50)

            
            //                .overlay(
            //                    HStack(spacing: 15) {
            //                        ForEach(colors.indices, id: \.self) { index in
            //                            Capsule()
            //                                .fill(Color.white)
            //                                .frame(width: 7, height: 7)
            //                        }
            //                    }
            //                        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            //                        .padding(.bottom,10)
            //                    ,alignment: .bottom
            //                )
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
   
        
    }
    
    func nextPage() {
        pageIndex += 1
    }
    
}

struct Intro1: View {
    @Binding var pageIndex: Int
    var body: some View {
        
        VStack{
            Text("Hello World")
                .foregroundColor(.white)
            Button {
                pageIndex+=1
            } label: {
                Text("Click me")
            }

        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(K.finalColor.cardBlue)
            .cornerRadius(30)
        
        
    }
}

struct Intro2: View {
    @Binding var pageIndex: Int
    var body: some View {
        
        VStack{
            Text("Hello ")
                .foregroundColor(.white)
            Button {
                pageIndex+=1
            } label: {
                Text("Click me")
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(K.finalColor.cardBlue)
            .cornerRadius(30)
        
        
    }
}

struct Intro3: View {
    @Binding var pageIndex: Int
    var body: some View {
        
        VStack{
            GifImage("Iphone")
                .frame(width: 500,height: 250)
            
            Text(" World")
                .foregroundColor(.white)
            Button {
                pageIndex+=1
            } label: {
                Text("Click me")
            }
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(K.finalColor.cardBlue)
            .cornerRadius(30)
        
        
    }
}




struct SignupIntro_Previews: PreviewProvider {
    static var previews: some View {
        SignupIntro()
    }
}
