//
//  screen1.swift
//  Weekly Winner
//
//  Created by Johnny Perkins on 5/26/23.
//

import SwiftUI
import Firebase
import Kingfisher
import SafariServices
import WebKit






struct UserProfileView: View {
    @ObservedObject private var screen1VM = screen1ViewModel()
   // @StateObject var countdownTimer = CountdownTimer()
    @State private var showWebpage = false
    @Binding var tab: Tab
    @State var timeFrame = "daily"
    @StateObject private var prizesVM = prizesViewModel()

    

    
    var body: some View {
        VStack(spacing: 12) {

            ProfileHeaderView(screen1VM: screen1VM, timeFrame: $timeFrame)
                .padding(.top, 10)
                .padding(.horizontal)
           
            countDown(prizesVM: prizesVM, timeFrame: $timeFrame)
            
        //    testView()

            VStack {
             yourGroups(screen1VM: screen1VM, tab: $tab)
                    .padding(.horizontal)

                weeklyGlobalLeaders(screen1VM: screen1VM, timeFrame: $timeFrame)
                    .padding(.horizontal)
                
                
                Spacer()
            }.padding(.bottom,45)

        }
        .sheet(isPresented: $showWebpage) {
            SafariView(url: URL(string: screen1VM.updateURL)!)
        }
       
        
        .background(K.finalColor.backgroundBlue)
        .onAppear() {
            screen1VM.forceUpdate () {
                if screen1VM.updateURL != ""{
                    AppUtility.shared.showCustomAlert(alertType: .none, message: "There is a new, necessary update. Sorry we know this is annoying...", actionButtonTitle: K.appButtonTitle.ok, cancelButtonTitle: nil) { action in
                        if action == AlertButtonAction.okButton{
                            showWebpage.toggle()
                        }
                        
                    }
                }
            }
        }.padding(.top, 35)
    }
}



struct ScreenA: View {
    var body: some View {
        Text("helloA")
    }
}

struct ScreenB: View {
    var body: some View {
        Text("helloB")
    }
}

struct testView: View {
    @State private var currentScreen: Int = 0 // 0 for Screen A, 1 for Screen B
    @State private var dragTranslation: CGFloat = 0


    var body: some View {
        VStack {
            // Title and Button views
            HStack {
                Button("Screen A") {
                    withAnimation {
                        currentScreen = 0
                    }
                }
                Button("Screen B") {
                    withAnimation {
                        currentScreen = 1
                    }
                }
            }.overlay(
                Rectangle()
                    .frame(width: 50, height: 10)
                    .offset(x: (currentScreen == 0 ? 0 : 50) + dragTranslation / 2, y: 0)
                    .animation(.linear, value: dragTranslation)
                    .animation(.linear, value: currentScreen)
            , alignment: .bottom)

            // Screen sliding view
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ScreenA()
                        .frame(width: geometry.size.width)
                    ScreenB()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(currentScreen) * geometry.size.width, y: 0)
                .animation(.easeInOut, value: currentScreen)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            dragTranslation = gesture.translation.width
                        }
                        .onEnded { gesture in
                            dragTranslation = 0
                            if gesture.translation.width > 50 {
                                // Swiped to the right
                                withAnimation {
                                    currentScreen = max(0, currentScreen - 1)
                                }
                            } else if gesture.translation.width < -50 {
                                // Swiped to the left
                                withAnimation {
                                    currentScreen = min(1, currentScreen + 1)
                                }
                            }
                        }
                )

            }
        }
    }
}





struct weeklyGlobalLeaders: View {
    @StateObject var screen1VM: screen1ViewModel
    @Binding var timeFrame: String
    
    var body: some View {
        ZStack() {
            VStack(alignment: .center) {
            
                Text("\(timeFrame == "daily" ? "Daily" : "Weekly") Leaders")
                    .font(.custom(K.customFonts.lexendDecaMedium, size: 24).weight(.medium))
                    .foregroundColor(.white)
                if timeFrame == "daily" {
                    if screen1VM.canFetchDailyRankedTickets {
                        ForEach(0..<min(3, StaticUserData.shared.dailyRankedTickets.count), id: \.self) { index in
                            let ticket = StaticUserData.shared.dailyRankedTickets[index]
                            
                            BetCard(
                                ticket: ticket,
                                rank: ticket.rank,
                                ownCard: false,
                                currentWeek: true,
                                homePage: true
                            ).padding(EdgeInsets(top: 0, leading: 8, bottom: 5, trailing: 8))
                        }
                    }
                } else if timeFrame == "weekly" {
                    if screen1VM.canFetchWeeklyRankedTickets {
                        
                        ForEach(0..<min(3, StaticUserData.shared.weeklyRankedTickets.count), id: \.self) { index in
                            let ticket = StaticUserData.shared.weeklyRankedTickets[index]
                            
                            BetCard(
                                ticket: ticket,
                                rank: ticket.rank,
                                ownCard: false,
                                currentWeek: true,
                                homePage: true
                            ).padding(EdgeInsets(top: 0, leading: 8, bottom: 5, trailing: 8))
                        }
                    }
                }
                
            }.frame(height: 210)
        }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 230, maxHeight: 230)
    .background(.clear)
    .cornerRadius(10)
    .padding(.top,15)

    }
}


struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // Update the view controller if needed
    }
}

struct ProfileHeaderView: View {
    @State private var showWebpage = false
    @State private var showRulesPage = false
    @ObservedObject var screen1VM: screen1ViewModel
    @Binding var timeFrame: String
    

    var body: some View {
        HStack() {
            
            NavigationLink(destination: settingsView()) {
                
                
                if screen1VM.currentUser?.profileImageUrl != nil {
                    KFImage(URL(string: StaticUserData.shared.currentUser.profileImageUrl))
                        .resizable()
                        .clipShape(Circle())
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 30)
                }else {
                    Image("sampleImage")
                        .resizable()
                        .foregroundColor(.clear)
                        .frame(width: 30, height: 30)
                }
                Text("\(screen1VM.currentUser?.username ?? "")")
                    .font(.custom(K.customFonts.lexendDecaSB, size: 18))
                    .foregroundColor(.white)
            }
            Spacer()

//            Link("@WagerPool", destination: URL(string: "https://www.instagram.com/wagerpool/")!)
//                .font(.custom(K.customFonts.lexendDecaSB, size: 18))
//                .foregroundColor(.white)
//                .frame(height: 50)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bitcoinsign.circle")
                        .resizable()
                        .foregroundStyle(.yellow)
                        .frame(width: 15, height: 15)
                    Text("\(String(format: "%.0f", StaticUserData.shared.currentUser.poolCoins))")
                        .foregroundStyle(.white)
                        .font(.custom(K.customFonts.lexendDecaSB, size: 14))
                }
                HStack {
                    Image(systemName: "dollarsign.square.fill")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: 15, height: 15)
                    Text("\(String(format: "%.0f", StaticUserData.shared.currentUser.poolBucks))")
                        .foregroundStyle(.white)
                        .font(.custom(K.customFonts.lexendDecaSB, size: 14))
                }

            }
            
        }
        .padding(.top,15)
//        .sheet(isPresented: $showRulesPage) {
//            rulesView()
//                .presentationDetents([.fraction(0.65)])
//                .presentationDragIndicator(.hidden)
//                .background(K.finalColor.backgroundBlue)
//        }
    }
}

struct rulesView: View {
    var body: some View {
        ZStack {
            K.finalColor.backgroundBlue
            ScrollView {
                K.finalColor.backgroundBlue
                VStack (spacing: 5) {
                    Text("How To Play WagerPool?")
                        .font(.custom(K.customFonts.lexendDecaSB, size: 20))
                        .foregroundColor(K.finalColor.titleBlue)
                        .padding(.vertical)
                    
                    Text("     WagerPool is a FREE TO PLAY social sportsbook where players can place risk free bets in an attempt to win real prizes. ")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                    
                    Text("To start, go to the Bets page.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding(.bottom)
                    
                    Image("howTo1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("Then, pick a game.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("Choose a spread or total.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("Choose the daily or weekly challenge + the corresponding bet you would like to fill.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("Choose your odds and place your bet.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo5")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("You can then see your bets on the ticket page.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo6")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("You are ranked against other players for both the daily and weekly challenges. Orange = Pending, Green = Won.")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                    Image("howTo7")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .cornerRadius(5)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    
                    Text("When the day/week ends, winning players can receive their prizes by dming @WagerPool on instagram!")
                        .font(.custom(K.customFonts.lexendDecaMedium, size: 15))
                        .foregroundColor(K.finalColor.textWhite)
                        .padding()
                    
                }.padding(.horizontal)
            }
        }
    }
}


struct countDown: View {
    @StateObject var countdownTimer = CountdownTimer()
    @ObservedObject var prizesVM: prizesViewModel
    @Binding var timeFrame: String
    
    init(prizesVM: prizesViewModel, timeFrame: Binding<String>) {
        self.prizesVM = prizesVM
        self._timeFrame = timeFrame
    }
    var body: some View {
        ZStack() {
            VStack(alignment: .center) {
                
                VStack (spacing: 3){
                    HStack (spacing: 0){
                        Button(action: {
                            //viewModel.canGetHistoricalData = false
                            if timeFrame != "daily" {
                                withAnimation {
                                    timeFrame = "daily"
//                                    viewModel.fetchCurrentRankedTickets(groupID: StaticUserData.shared.dailyTicket.groupID, timeFrame: timeFrame) {
//                                    }
//                                    showingChat = false
                                }
                            }
                            
                        }) {
                            //Text(viewModel.userTickets[self.selectedGroup-1].groupName)
                            Text("Daily")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 20, alignment: .center)
                                //.background(timeFrame == "daily" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                .cornerRadius(5)
                        }.scaleEffect(timeFrame == "daily" ? 1.0 : 1.0)
                        
                        Button(action: {
                            //viewModel.canGetHistoricalData = false
                            if timeFrame == "daily" {
                                
                                withAnimation {
                                    timeFrame = "weekly"
                                }
                            }
                            
                        }) {
                            Text("Weekly")
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 20, alignment: .center)
                                //.background(timeFrame == "weekly" ? K.finalColor.titleBlue : K.finalColor.cardBlue)
                                .cornerRadius(5)
                        }.scaleEffect(timeFrame == "weekly" ? 1.0 : 1.0)
                    }.padding(.top, 2)
                    Rectangle()
                        .fill(Color.white) // Sets the rectangle's fill color to white
                        .frame(width: 90, height: 3)
                        .cornerRadius(1) // Apply rounded corners
                        .offset(x: timeFrame == "daily" ? -50 : 50, y: 0)
                        .animation(.easeInOut(duration: 0.5))
                }

                VStack(spacing: 0) {
                    if timeFrame == "daily" {
                        Text(countdownTimer.dayTimeRemaining)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 22))
                            .foregroundColor(.white)
                            .padding(.vertical)
                    } else if timeFrame == "weekly" {
                        Text(countdownTimer.weekTimeRemaining)
                            .font(.custom(K.customFonts.lexendDecaMedium, size: 22))
                            .foregroundColor(.white)
                            .padding(.vertical)
                    }
                }
                .frame(height: 20).padding(.top,3)
                    
                HStack{
                    
                    ForEach(0..<3, id: \.self) { index in
                        HStack {
                            if index == 0 {
                                Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            } else if index == 1 {
                                Image(systemName: "trophy.fill")
                                .foregroundColor(Color(hex: "C0C0C0"))
                            } else if index == 2 {
                                Image(systemName: "trophy.fill")
                                .foregroundColor(Color(hex: "9F7A34"))
                            }
                            


                            Text("$")
                                .foregroundColor(.white)
                                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                            if prizesVM.canViewPrizes == true && prizesVM.canViewDailyPrizes == true{
                                if timeFrame != "daily" {
                                    Text("\(prizesVM.prizes[index])  ")
                                        .foregroundColor(.white)
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .padding(.leading,-8)
                                }
                                else {
                                    Text("\(prizesVM.dailyPrizes[index])  ")
                                        .foregroundColor(.white)
                                        .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                                        .padding(.leading,-8)
                                }
                            }
                        }.frame(width: 100, height: 30)
                            .padding(3)
                            .background(K.finalColor.titleBlue.opacity(0.5))
                            .cornerRadius(5)
                    }
                }
                .padding(.top,5)
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 130, maxHeight: 130)
            .background(K.finalColor.cardBlue)
            .cornerRadius(10)
            .padding(.horizontal, 16)
        }
    }


struct yourGroups: View {
    @StateObject var screen1VM: screen1ViewModel
    @Binding var tab: Tab
    @State private var showRulesPage = false

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Your Groups")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 24).weight(.medium))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<2, id: \.self) { index in
                        // Use your custom view or data here.
                        // Replace `Text("Item \(index)")` with your custom view
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 3) {
                                
                                if screen1VM.userGroupsLoaded {
                                    if screen1VM.userGroups[0].groupImageURL != "" {
                                        HStack {
                                            Spacer()
                                            KFImage(URL(string: screen1VM.userGroups[0].groupImageURL))
                                                .resizable()
                                                .cornerRadius(7.5)
                                                .foregroundColor(.clear)
                                                .scaledToFit()
                                                .frame(height: 95)
                                            Spacer()
                                        }
                                    }
                                    else {
                                        Image(systemName: "photo.circle.fill")
                                            .resizable()
                                            .cornerRadius(7.5)
                                            .foregroundColor(.clear)
                                            .scaledToFit()
                                            .frame(height: 95)
                                    }
                                    HStack(alignment: .top) {
                                        Spacer()
                                        Text("\(index == 0 ? "Daily" : "Weekly")")
                                            .font(.custom(K.customFonts.poppinsMedium, size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                }
                               
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                HStack() {
                                    Text("Rank")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("#\(index == 0 ? StaticUserData.shared.dailyTicket.rank : StaticUserData.shared.weeklyTicket.rank)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                                HStack() {
                                    Text("Pending")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(index == 0 ? StaticUserData.shared.dailyTicket.totalPotentialWon : StaticUserData.shared.weeklyTicket.totalPotentialWon)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                                HStack() {
                                    Text("Total Won")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 12))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(index == 0 ? StaticUserData.shared.dailyTicket.totalWon : StaticUserData.shared.weeklyTicket.totalWon)")
                                        .font(.custom(K.customFonts.poppinsRegular, size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(10)
                        .frame(width: 135, height: 205)
                        .background(self.backgroundColor(for: index))
                        .cornerRadius(12)
                        .overlay(self.overlayShape(for: index))
                    }
                    
                    Button {
                    
                        showRulesPage.toggle()
                        
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 3) {
                                
                                HStack {
                                    Spacer()
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .cornerRadius(7.5)
                                        .foregroundColor(.white)
                                        .scaledToFit()
                                        .frame(height: 80)
                                    Spacer()
                                }
                                HStack(alignment: .top) {
                                    Spacer()
                                    Text("How To Play?")
                                        .font(.custom(K.customFonts.poppinsMedium, size: 20))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                        .padding(10)
                        .frame(width: 140, height: 205)
                        .background(K.finalColor.backgroundBlue)
                        .cornerRadius(12)
                        .overlay(self.overlayShape(for: 1))
                    }
                    
//                    NavigationView {
//                        // Your other content...
// 
//                            NavigationLink(destination: purchaseView()) {
//                                VStack(alignment: .leading, spacing: 8) {
//                                    VStack(alignment: .leading, spacing: 3) {
//                                        HStack {
//                                            Spacer()
//                                            Image(systemName: "questionmark.circle")
//                                                .resizable()
//                                                .cornerRadius(7.5)
//                                                .foregroundColor(.white)
//                                                .scaledToFit()
//                                                .frame(height: 80)
//                                            Spacer()
//                                        }
//                                        HStack(alignment: .top) {
//                                            Spacer()
//                                            Text("Purchase PoolCoins!")
//                                                .font(.custom(K.customFonts.poppinsMedium, size: 20))
//                                                .foregroundColor(.white)
//                                            Spacer()
//                                        }
//                                    }
//                                }
//                                
//                            }
//                        
//
//                        // Your other content...
//                    }.padding(10)
//                        .frame(width: 140, height: 205)
//                        .background(K.finalColor.backgroundBlue)
//                        .cornerRadius(12)
//                        .overlay(self.overlayShape(for: 1))

                    
                }
            }
        }.sheet(isPresented: $showRulesPage) {
            rulesView()
            //.padding(.horizontal)
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.hidden)
                .background(K.finalColor.backgroundBlue)
        }
    }
    func backgroundColor(for index: Int) -> LinearGradient {
        if index % 3 == 0 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.57, green: 0.56, blue: 0.98), Color(red: 0.85, green: 0.58, blue: 0.99)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if index % 3 == 1 {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.16, green: 0.62, blue: 0.52), Color(red: 0.59, green: 0.79, blue: 0.44)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.54, blue: 0.51), Color(red: 0.97, green: 0.69, blue: 0.46)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    func overlayShape(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(self.overlayColor(for: index), lineWidth: 0.50)
    }
    
    func overlayColor(for index: Int) -> Color {
        if index % 3 == 0 {
            return Color(red: 0.14, green: 0.61, blue: 0.85)
        } else if index % 3 == 1 {
            return Color(red: 0.15, green: 0.90, blue: 0.69)
        } else {
            return Color(red: 1, green: 0.74, blue: 0.60)
        }
    }
}

struct MostPopularBetsView: View {
    @StateObject var bookVM: bookViewModel
    var body: some View {
        VStack (alignment: .center, spacing: 15) {
            Text("Most Popular Bets")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 24))
                    .foregroundColor(.white)
            VStack {
                ForEach(0..<bookVM.mostPopularBets.count, id: \.self) { index in
                    if index < 5 {
                        PopularBetView(index: index, bookVM: bookVM)
                    }
                }
            }
        }
    }
}


struct PopularBetView: View {
    let index: Int
    @StateObject var bookVM: bookViewModel
    private var extra: String {
        if bookVM.mostPopularBets[index].betType == .over {
            return "O"
        } else if bookVM.mostPopularBets[index].betType == .under {
            return "U"
        } else {
            if bookVM.mostPopularBets[index].betLine >= 0 {
                return "+"
            }
        }
        return ""
    }

    var body: some View {
        
        HStack (spacing: 0) {
            //Spacer()
            Text("\(index + 1).")
                .font(.custom(K.customFonts.lexendDecaMedium, size: 16))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 10))

            Text("\(bookVM.mostPopularBets[index].teamName) \(extra)\(bookVM.mostPopularBets[index].betLine)")
                .font(.custom(K.customFonts.lexendDecaMedium, size:
                                bookVM.mostPopularBets[index].teamName.count < 20 ? 16 : 13))
                             //   (bet.teamBetOn?.count ?? 10 > 35 ? 9: 11)))

                .foregroundColor(.white)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5))
                .cornerRadius(7.5)
                .frame(maxWidth: 300, alignment: .leading)
        }.frame(maxWidth: .infinity, maxHeight: 40) // This line
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(K.finalColor.cardBlue)
        .overlay(self.overlayShape(for: 2))
        .cornerRadius(7.5)
        

    }
    
    func overlayShape(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(self.overlayColor(for: index), lineWidth: 0.50)
    }
    
    func overlayColor(for index: Int) -> Color {
        if index % 3 == 0 {
            return Color(red: 0.14, green: 0.61, blue: 0.85)
        } else if index % 3 == 1 {
            return Color(red: 0.15, green: 0.90, blue: 0.69)
        } else {
            return Color(red: 1, green: 0.74, blue: 0.60)
        }
    }
    
}

//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfileView(tab: .dashboard)
//    }
//}
