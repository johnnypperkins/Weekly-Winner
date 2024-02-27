//
//  sportsSelecterView.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 7/9/23.
//

import SwiftUI

struct sideMenuView: View {
    @ObservedObject var bookVM: bookViewModel
    
    @Binding var isShowing: Bool
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color.blue,Color.red]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack{
                //sideMenuHeaderView(isShowing: $isShowing)
                  //  .frame(height: 240)
                
                ForEach(sportsSelecterViewModel.allCases, id: \.self) { option in
                    Button {
                        bookVM.selectedGameType = option.title
                        withAnimation(.spring()) {
                            isShowing.toggle()
                        }
                    } label: {
                        HStack (spacing: 16){
                            Image(systemName: option.imageName)
                                .frame(width: 24, height: 24)
                            
                            Text(option.title)
                                .font(.system(size: bookVM.selectedGameType == option.title ? 20 : 15, weight: bookVM.selectedGameType == option.title ? .bold : .semibold))
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                }
                Spacer()
            }.padding(.top,50)
        }//
    }

    enum GameType: String, CaseIterable, Hashable {
        case collegeFootball = "College Football"
        case nfl = "NFL"
        case nba = "NBA"
        case ncaab = "NCAAB"
        case nhl = "NHL"
    }
}



struct sideMenuCell: View {
    var viewModel: sportsSelecterViewModel
    var body: some View {
        HStack (spacing: 16){
            Image(systemName: viewModel.imageName)
                .frame(width: 24, height: 24)
            
            Text(viewModel.title)
                .font(.system(size: 15, weight: .semibold))
            
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        
    }
}

//struct sideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        sideMenuView(isShowing: .constant(true))
//    }
//}
