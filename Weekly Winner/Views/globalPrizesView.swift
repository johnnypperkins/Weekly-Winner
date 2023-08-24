//
//  globalPrizesView.swift
//  Weekly Winner
//
//  Created by Reid Brown (Test) on 8/20/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase

struct globalPrizesView: View {
    @StateObject private var viewModel = prizesViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                K.finalColor.backgroundBlue.ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Text("WEEKLY GLOBAL PRIZES")
                            .foregroundColor(.white)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                            .padding(.bottom)
                        Spacer()
                    }
                    HStack (alignment: .center){
                        VStack (alignment: .leading, spacing: 10){
                            Text("1st Place: ")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            Text("2nd Place: ")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            Text("3rd Place: ")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            Text("4th Place: ")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            Text("5th Place: ")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                        }
                        if viewModel.canViewPrizes {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("$\(viewModel.prizes[0])")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                Text("$\(viewModel.prizes[1])")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                Text("$\(viewModel.prizes[2])")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                Text("$\(viewModel.prizes[3])")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                                Text("$\(viewModel.prizes[4])")
                                    .foregroundColor(.white)
                                    .font(.custom(K.customFonts.lexendDecaMedium, size: 20))
                            }
                        }
                    }
                }
            }
        }
    }
}
