//
//  screen2.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI

enum GameType: String, CaseIterable {
    case collegeFootball = "College Football"
    case nfl = "NFL"
}

struct BettingAppView: View {
    @State private var selectedGameType = GameType.collegeFootball
    @ObservedObject private var viewModel = bookViewModel()
    @State private var showingSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Betting App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                    
                    Picker("", selection: $selectedGameType) {
                        ForEach(GameType.allCases, id: \.self) { gameType in
                            Text(gameType.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.NFLgames, id: \.idd) { game in
                            BetRowView1(game: game)
                            }
                    }
                    .padding()
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarHidden(true)
        }
    }
    
    /*private var filteredGames: [Game] {
        switch selectedGameType {
        case .collegeFootball:
            return ""
        case .nfl:
            return ""
        }
    }*/
}

struct BetRowView1: View {
    let game: Game
    @State private var showingAway = false
    @State private var showingTotal = false
    @State private var showingHome = false
    @State private var showingSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack{
                    Text(game.awayTeam)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Text("@\(game.homeTeam)")
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                
                HStack(spacing: 10) {
                    Button(action: {
                        self.showingAway.toggle()
                        self.showingSheet.toggle()
                            }) {
                                Text("\(game.awaySpread, specifier: "%.1f")")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color(showingAway ? .gray : .clear))
                                    .cornerRadius(20)
                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color.black, lineWidth: 1)
                                                    )
                                    .shadow(color: showingAway ? .gray : .clear, radius: 5)
                                    .scaleEffect(showingAway ? 0.8 : 1.0)
                                    .animation(.spring(), value: 4)
                            }
                        
                    Spacer()
                    Button(action: {
                                self.showingTotal.toggle()
                        self.showingSheet.toggle()
                    }) {
                        HStack{
                            Image(systemName: "arrow.up.arrow.down")
                                .padding(.leading)
                            Text("\(game.totalOU, specifier: "%.1f")")
                                .foregroundColor(.blue)
                                .padding()
                        }
                        .background(Color(showingTotal ? .gray : .white))
                        .cornerRadius(20)
                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 1)
                                        )
                        .shadow(color: showingTotal ? .gray : .clear, radius: 5)
                        .scaleEffect(showingTotal ? 0.9 : 1.0)
                        .animation(.spring(), value: 4)
                    }
                    Spacer()
                    Button(action: {
                                self.showingHome.toggle()
                        self.showingSheet.toggle()
                            }) {
                                Text("\(game.homeSpread, specifier: "%.1f")")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color(showingHome ? .gray : .white))
                                    .cornerRadius(10)
                                    .shadow(color: showingHome ? .gray : .clear, radius: 5)
                                    .scaleEffect(showingHome ? 0.9 : 1.0)
                                    .animation(.spring(), value: 4)
                            }
                }.padding(.top,4)
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding()
        
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingSheet) {
            BetDetailsView(game: game, showingAway: $showingAway, showingHome: $showingHome, showingTotal: $showingTotal)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
    }
}



struct BetDetailsView: View {
    let game: Game
    @Binding var showingAway: Bool
    @Binding var showingHome: Bool
    @Binding var showingTotal: Bool
    @Environment(\.dismiss) var dismiss
    @State private var userRating: Double = 2
    
    
    var body: some View {
        VStack {
            HStack{
                Button {
                    withAnimation {
                        dismiss()
                        showingAway = false
                        showingHome = false
                        showingTotal = false
                    }
                } label: {
                    Image(systemName: "arrow.turn.left.up")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .foregroundColor(.black)
                }
                Spacer()
                
                Text("Create Your Bet")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
            }.frame(maxWidth:.infinity, alignment: .center)
                .padding(.leading)
            
            if showingAway {
                VStack{
                    Text("Team: \(game.awayTeam)")
                        .font(.headline)
                    
                    HStack {
                        Text("Rate This Bar:")
                            .font(.headline)
                        Slider(value: $userRating, in: Double(game.awaySpread - 5)...Double(game.awaySpread + 5), step: 0.5) { editing in
                            if editing == false {
                                
                            }
                        }
                        .accentColor(Color(.green))
                        
                        Text(String(format: "%.1f", userRating))
                            .font(.headline)
                    }
                    .padding()
                    
                    Text("Spread: \(game.totalOU)")
                        .font(.subheadline)
                    
                    Text("Over/Under: \(game.awayTeam)")
                        .font(.subheadline)
                    
                    Divider()
                }}
            if showingHome {
                VStack{
                    Text("Team: \(game.homeTeam)")
                        .font(.headline)
                    
                    HStack {
                        Text("Rate This Bar:")
                            .font(.headline)
                        Slider(value: $userRating, in: Double(game.homeSpread - 5)...Double(game.homeSpread + 5), step: 0.5) { editing in
                            if editing == false {
                                
                            }
                        }
                        .accentColor(Color(.green))
                        
                        Text(String(format: "%.1f", userRating))
                            .font(.headline)
                    }
                    .padding()
                    
                    Text("Spread: \(game.totalOU, specifier: "%.1f")")
                        .font(.subheadline)
                    
                    Text("Over/Under: \(game.awayTeam)")
                        .font(.subheadline)
                    
                    Divider()
                    
                    
                }}
            
            if showingTotal {
                VStack{
                    Text("Team: \(game.awayTeam)")
                        .font(.headline)
                    
                    HStack {
                        Text("Rate This Bar:")
                            .font(.headline)
                        Slider(value: $userRating, in: Double(game.awaySpread - 5)...Double(game.awaySpread + 5), step: 0.5) { editing in
                            if editing == false {
                                
                            }
                        }
                        .accentColor(Color(.green))
                        
                        Text(String(format: "%.1f", userRating))
                            .font(.headline)
                    }
                    .padding()
                    
                    Text("Spread: \(game.totalOU)")
                        .font(.subheadline)
                    
                    Text("Over/Under: \(game.awayTeam)")
                        .font(.subheadline)
                    
                    Divider()
                    
                
                }}
            
            Button(action: {
                       // Place bet action
                   }) {
                       Text("Place Bet")
                           .font(.title)
                           .fontWeight(.bold)
                           .foregroundColor(.white)
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(
                               LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                           )
                           .cornerRadius(10)
                           .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                   }
        }.onAppear(perform: {
            if showingAway {
                userRating = game.awaySpread}
            if showingHome {
                userRating = game.homeSpread}
            if showingTotal {
                userRating = game.totalOU}
            
        })
    }
    
}



struct BettingAppView_Previews: PreviewProvider {
    static var previews: some View {
        BettingAppView()
    }
}

