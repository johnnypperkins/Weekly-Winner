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
    @ObservedObject var viewModel: authenticationViewModel
    
    
    
    var body: some View {
        //        ScrollView(.init()){
        NavigationStack{
            VStack{
                HStack{
                    Text("WagerPool")
                        .font(.custom(K.customFonts.lexendDecaSB, size: 35))
                        .foregroundColor(K.finalColor.titleBlue)
                    Spacer()
//                    if pageIndex < 2 {
                        NavigationLink (destination:{
                            tabBarView(selection: .dashboard)
                                .environmentObject(viewModel)
                        }, label: {
                            HStack{
                                
                                Spacer()
                                
                                Text("Skip")
                                    .font(Font.custom(K.customFonts.lexendDecaMedium, size: 12))
                                    .foregroundColor(pageIndex == 2 ? .clear : .white)
                                //shadow
                                
                                Spacer()
                            }.frame(minWidth: 0, maxWidth: 60, minHeight: 30 , maxHeight: 30)
                                .background(pageIndex == 2 ? .clear : Color(red: 0.31, green: 0.57, blue: 1))
                                .cornerRadius(10)
                                .padding(16)
                        }).onSubmit {
                            viewModel.showMainScreen()
                        }
//                    }
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
                            withAnimation{
                                pageIndex += 1
                            }
                        } label: {
                            Image(systemName: "arrow.forward")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.white)
                        }
                    } else {
                        NavigationLink (destination: {
                            tabBarView(selection: .dashboard)
                                .environmentObject(viewModel)
                        }, label: {
                            Text("Continue")
                                .font(Font.custom(K.customFonts.lexendDecaMedium, size: 14))
                                .foregroundColor(.white)
                            //shadow
                            
                            
                        }).onSubmit {
                            viewModel.showMainScreen()
                        }
                        .frame(minWidth: 0, maxWidth: 80, minHeight: 35 , maxHeight: 35)
                        .background(Color(red: 0.31, green: 0.57, blue: 1))
                        .cornerRadius(10)
                        
                        
                    }
                }.padding(.horizontal, 25)
                    .padding(.top,20)
                    .padding(.bottom,50)

            }.padding(.top,45)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            
        }.ignoresSafeArea()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(red: 0.02, green: 0.05, blue: 0.26))
            
                .navigationBarBackButtonHidden(true)
            
            
        
    }
    func nextPage() {
        pageIndex += 1
    }
    
}

struct Intro2: View {
    @Binding var pageIndex: Int
    @State private var isGlowing = false
    var body: some View {
        
        VStack{
            Image("groupsImage")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .padding(.top, 10)
//                .overlay(
//                                    Circle()
//                                        .stroke(Color.blue, lineWidth: 3) // Customize the color and width of the outline
//                                        .frame(width: 30, height: 30) // Adjust the size of the circle as needed
//                                        .offset(x: 2, y: 0) // Adjust the offset to position the circle in the top-left corner
//                                        .blur(radius:isGlowing ? 2.0 : 0)
//                                        .opacity(isGlowing ? 1.0 : 0.3)
//                                    ,alignment: .topLeading
//                                    // Opacity for the glow effect
//                                        
//                                )
//                .onAppear() {
//                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
//                                        self.isGlowing.toggle()
//                                    }
//                                }
            HStack{
                Text("Compete Daily and Weekly")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                    .foregroundColor(K.finalColor.textWhite)
                    .padding(.top,15)
                
            }.padding(.horizontal,15)
            
            Text("There is only one thing more valuable than money: bragging rights (but money is nice too). Compete against other sports enthusiasts in your daily and weekly cards to see who is the best at sports betting. The top players win REAL PRIZES!")
                .font(.custom(K.customFonts.lexendDecaLight, size: 15))
                .foregroundColor(K.finalColor.textWhite)
                .padding(.top,20)
                .padding(.horizontal,15)
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(K.finalColor.cardBlue)
            .cornerRadius(30)
        
        
    }
}

struct Intro1: View {
    @Binding var pageIndex: Int
    var body: some View {
        
        VStack{
            
            Image("bets")
                .resizable()
                .frame(width: 380,height: 380)
                .padding(.top,-40)
            HStack{
                Text("Place Bets")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                    .foregroundColor(K.finalColor.textWhite)
                    .padding(.top,-50)
                
            }.padding(.horizontal,15)
            
            Text("Complete your daily and weekly tickets with customized FREE TO PLACE bets from the book page. Bet on your favorite teams across many different sports! Tailor your bet odds using the slider to fit your risk tolerance. ")
                .font(.custom(K.customFonts.lexendDecaLight, size: 15))
                .foregroundColor(K.finalColor.textWhite)
                .padding(.top,20)
                .padding(.horizontal,15)
            
            Spacer()
            
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
            
            HStack{
                Text("Welcome!")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 25))
                    .foregroundColor(K.finalColor.textWhite)
                    .padding(.top,25)
                
            }.padding(.horizontal,15)
            
            Text("Good luck with your bets this week. We look forward to seeing you at the top of the leaderboard!  ")
                .font(.custom(K.customFonts.lexendDecaLight, size: 15))
                .foregroundColor(K.finalColor.textWhite)
                .padding(.top,20)
                .padding(.horizontal,15)
            Spacer()
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(K.finalColor.cardBlue)
            .cornerRadius(30)
        
        
    }
}




struct SignupIntro_Previews: PreviewProvider {
    static var previews: some View {
        SignupIntro(viewModel: authenticationViewModel())
    }
}
