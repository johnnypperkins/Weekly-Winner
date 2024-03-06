//
//  splashScreenView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 8/14/23.
//


import SwiftUI

struct splashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            ContentView() // ContentView is initialized behind the splash screen
                .opacity(isActive ? 1 : 0) // ContentView opacity controlled by isActive

            if !isActive {
                VStack {
                    Text("WagerPool")
                        .font(Font.custom(K.customFonts.lexendDecaSB, size: 50).weight(.semibold))
                        .foregroundColor(Color(red: 0.31, green: 0.57, blue: 1))
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.4)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                        withAnimation(.easeOut(duration: 1.4)) {
                            self.isActive = true
//                        }
                    }
                }
            }
        }
    }
}



struct splashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        splashScreenView()
    }
}

