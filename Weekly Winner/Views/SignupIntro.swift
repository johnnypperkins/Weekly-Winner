//
//  SignupIntro.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 11/10/23.
//

import SwiftUI

struct SignupIntro: View {
    @State var offset: CGFloat = 0
    
    var colors: [Color] = [.red,.blue,.pink]
    
    
    var body: some View {
        ScrollView(.init()){
            TabView{
                
                ForEach(colors.indices, id: \.self) { index in
                    if index == 1 {
                        colors[index]
                            .overlay(
                                GeometryReader {proxy -> Color in
                                    let minX = proxy.frame(in: .global).minX
                                    DispatchQueue.main.async {
                                        withAnimation(.default) {
                                            self.offset = -minX
                                        }
                                    }
                                    return Color.clear
                                }.frame(width: 0, height: 0)
                                ,alignment: .leading
                            )
                    }
                    else {
                        colors[index]
                    }
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .overlay(
                    HStack(spacing: 15) {
                        ForEach(colors.indices, id: \.self) { index in
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 7, height: 7)
                        }
                    }
                        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                        .padding(.bottom,10)
                    ,alignment: .bottom
                )
        }
            .ignoresSafeArea()
        
                       
        
        
        
        
        
        
//        GeometryReader { g in
//
//
//                HStack (spacing: 0){
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(width: g.size.width, height: g.size.height)
//
//                    Rectangle()
//                        .fill(Color.blue)
//                        .frame(width: g.size.width, height: g.size.height)
//
//                    Rectangle()
//                        .fill(Color.green)
//                        .frame(width: g.size.width, height: g.size.height)
//
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(width: g.size.width, height: g.size.height)
//
//                    Rectangle()
//                        .fill(Color.black)
//                        .frame(width: g.size.width, height: g.size.height)
//                }.offset(x: -(self.backgroundOffset))
//                .animation(.default, value: 5)
//                .gesture(
//                    DragGesture()
//                        .onEnded ({ value in
//                            self.backgroundOffset = g.size.width
//                        }))
//        }
//        .gesture(
//            DragGesture()
//                .onEnded ({ value in
//                    if value.translation.width > 10 {
//                        if self.backgroundOffset > 0 {
//                            self.backgroundOffset -= 1
//                        }
//                    }else if value.translation.width < -10{
//                                if self.backgroundOffset < 4 {
//                        self.backgroundOffset += 1
//                    }
//                    }
//                })
//
//        )
        
        
        
    }
    
}

struct SignupIntro_Previews: PreviewProvider {
    static var previews: some View {
        SignupIntro()
    }
}
